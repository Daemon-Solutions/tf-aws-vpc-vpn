output "vpc_id" {
  value = "${aws_vpc.vpc.id}"
}

output "vpc_cidr" {
  value = "${aws_vpc.vpc.cidr_block}"
}

output "availability_zones" {
  value = "${join(",", aws_subnet.public.*.availability_zone)}"
}

output "public_subnets" {
  value = "${join(",", aws_subnet.public.*.id)}"
}

output "public_route_tables" {
  value = "${join(",", aws_route_table.public.*.id)}"
}

output "nat_subnets" {
  value = "${join(",", aws_subnet.nat.*.id)}"
}

output "nat_route_tables" {
  value = "${join(",", aws_route_table.nat.*.id)}"
}

output "nat_enis" {
  value = "${join(",", aws_network_interface.nat.*.id)}"
}

output "vpn_gateway_id" {
  value = "${aws_vpn_gateway.vpngw.id}"
}
