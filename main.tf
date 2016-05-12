#
# VPC
#
resource "aws_vpc" "vpc" {
  cidr_block = "${var.cidr}"

  tags {
    Name = "${var.name}"
  }
}

resource "aws_vpc_dhcp_options" "vpc" {
  domain_name         = "${var.domain}"
  domain_name_servers = ["${split(",", var.domain_name_servers)}"]

  tags {
    Name = "${var.name}"
  }
}

resource "aws_vpc_dhcp_options_association" "vpc_dhcp" {
  vpc_id          = "${aws_vpc.vpc.id}"
  dhcp_options_id = "${aws_vpc_dhcp_options.vpc.id}"
}

#
# VPN GW
#
resource "aws_vpn_gateway" "vpngw" {
  vpc_id = "${aws_vpc.vpc.id}"

  tags {
    Name = "${var.name}-vpngw"
  }
}

resource "aws_customer_gateway" "cgw" {
  count      = "${length(split(",", var.cgw_ips))}"
  bgp_asn    = "${element(split(",", var.bgp_asn), count.index)}"
  ip_address = "${element(split(",", var.cgw_ips), count.index)}"
  type       = "ipsec.1"

  tags {
    Name = "${var.name}"
  }
}

resource "aws_vpn_connection" "main" {
  count               = "${length(split(",", var.cgw_ips))}"
  vpn_gateway_id      = "${aws_vpn_gateway.vpngw.id}"
  customer_gateway_id = "${element(aws_customer_gateway.cgw.*.id, count.index)}"
  type                = "ipsec.1"
  static_routes_only  = "false"

  tags {
    Name = "${var.name}"
  }
}

#
# Public Subnets
#
resource "aws_internet_gateway" "igw" {
  vpc_id = "${aws_vpc.vpc.id}"

  tags {
    Name = "${var.name}-igw"
  }
}

resource "aws_subnet" "public" {
  vpc_id                  = "${aws_vpc.vpc.id}"
  cidr_block              = "${element(split(",", var.public_subnets), count.index)}"
  availability_zone       = "${element(split(",", var.azs), count.index)}"
  count                   = "${length(split(",", var.public_subnets))}"
  map_public_ip_on_launch = "${var.map_public_ip_on_launch}"

  tags {
    Name = "${var.name}-public"
  }
}

resource "aws_route_table" "public" {
  vpc_id           = "${aws_vpc.vpc.id}"
  propagating_vgws = ["${aws_vpn_gateway.vpngw.id}"]

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.igw.id}"
  }

  tags {
    Name = "${var.name}-public-route"
  }
}

resource "aws_route_table_association" "public" {
  count          = "${length(split(",", var.public_subnets))}"
  subnet_id      = "${element(aws_subnet.public.*.id, count.index)}"
  route_table_id = "${aws_route_table.public.id}"
}

#
# NAT Subnets
#
resource "aws_security_group" "natgw" {
  name        = "${var.name}-natgw"
  description = "Security Group NAT-GW ${var.name}"
  vpc_id      = "${aws_vpc.vpc.id}"

  // allow internal traffic
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["${var.cidr}"]
  }

  // allow incoming ssh traffic
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${split(",", var.allowed_ssh_cidrs)}"]
  }

  // allow all outgoing
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "${var.name}-natgw"
  }
}

resource "aws_network_interface" "nat" {
  subnet_id         = "${element(aws_subnet.public.*.id, count.index)}"
  source_dest_check = "false"
  security_groups   = ["${aws_security_group.natgw.id}"]
  count             = "${length(split(",", var.public_subnets))}"

  tags {
    Name    = "${var.name}"
    Service = "bastion"
  }
}

resource "aws_eip" "nat" {
  depends_on        = ["aws_network_interface.nat"]
  network_interface = "${element(aws_network_interface.nat.*.id, count.index)}"
  count             = "${length(split(",", var.public_subnets))}"
  vpc               = true
}

resource "aws_subnet" "nat" {
  vpc_id            = "${aws_vpc.vpc.id}"
  cidr_block        = "${element(split(",", var.nat_subnets), count.index)}"
  availability_zone = "${element(split(",", var.azs), count.index)}"
  count             = "${length(split(",", var.nat_subnets))}"

  tags {
    Name = "${var.name}-nat"
  }
}

resource "aws_route_table" "nat" {
  depends_on       = ["aws_eip.nat"]
  vpc_id           = "${aws_vpc.vpc.id}"
  count            = "${length(split(",", var.nat_subnets))}"
  propagating_vgws = ["${aws_vpn_gateway.vpngw.id}"]

  route {
    cidr_block           = "0.0.0.0/0"
    network_interface_id = "${element(aws_network_interface.nat.*.id, count.index)}"
  }

  tags {
    Name = "${var.name}-nat-route"
  }
}

resource "aws_route_table_association" "nat" {
  count          = "${length(split(",", var.nat_subnets))}"
  subnet_id      = "${element(aws_subnet.nat.*.id, count.index)}"
  route_table_id = "${element(aws_route_table.nat.*.id, count.index)}"
}
