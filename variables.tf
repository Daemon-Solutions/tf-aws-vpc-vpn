variable "name" {
}

variable "allowed_ssh_cidrs" {
  default     = "88.97.72.136/32,54.76.122.23/32"
  description = "Allowed networks for SSH access"
}

variable "domain_name_servers" {
  default = "AmazonProvidedDNS"
}

# VPC
variable "cidr" {
  description = "IP range of VPC"
}

variable "domain" {
  default     = "eu-west-1.compute.internal"
  description = "Domain within VPC"
}

variable "azs" {
  description = "Availability zones (comma-separated)"
}

variable "public_subnets" {
}

variable "nat_subnets" {
}

variable "map_public_ip_on_launch" {
  default = false
}

# VPN
variable "cgw_ips" {
}

variable "bgp_asn" {
  default = "65000"
}
