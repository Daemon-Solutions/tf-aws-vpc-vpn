variable "name" {
  description = "Value for the 'Name' tag and interpolated into the resource name where appropriate"
  type = "string"
  default = "vpc-vpn"
}

variable "allowed_ssh_cidrs" {
  description = "Allowed networks for SSH access"
  type = "string"
  default = "88.97.72.136/32,54.76.122.23/32"
}

variable "domain_name_servers" {
  description = "Comma separated list of domain name servers to use for the VPC"
  type = "string"
  default = "AmazonProvidedDNS"
}

# VPC
variable "cidr" {
  description = "The IP range for the VPC"
  type = "string"
  default = "10.0.0.0/8"
}

variable "domain" {
  description = "The domain name to specify for use in the VPC"
  type = "string"
  default = "mydomain.compute.internal"
}

variable "azs" {
  description = "Comma separated list of AWS Availability zones to span resources across"
  type = "string"
  default = "eu-west-1a,eu-west-1b,eu-west-1c"
}

variable "public_subnets" {
  description = "Comma separated list of public subnet CIDR blocks to create"
  type = "string"
  default = "10.0.1.0/24,10.0.2.0/24"
}

variable "nat_subnets" {
  description = "Comma separated list of NAT subnet CIDR blocks to create"
  type = "string"
  default = "10.0.10.0/24,10.0.11.0/24"
}

variable "map_public_ip_on_launch" {
  description = "Bool indicating whether to map public IPs to instances on launch inside the subnets created by this module"
  type = "string"
  default = false
}

# VPN
variable "cgw_ips" {
  description = "Comma separated list of customer gateway IP addresses to use"
  type = "string"
}

variable "bgp_asn" {
  description = "The customer gateway's BGP Autonomous System Number (ASN)"
  type = "string"
  default = "65000"
}
