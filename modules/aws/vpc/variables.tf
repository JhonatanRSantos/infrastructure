variable "environment" {
  type        = string
  description = "Current environment name"
}

variable "create_vpc" {
  type        = bool
  default     = true
  description = "Controls if VPC should be created"
}

variable "name" {
  type        = string
  description = "VPC identifier"

  validation {
    condition     = length(trimspace(var.name)) > 3
    error_message = "All vpcs must have a valid name"
  }
}

variable "cidr_block" {
  type        = string
  default     = "10.0.0.0/16"
  description = "The IPv4 CIDR block for the VPC"
}

variable "enable_dns_support" {
  type        = bool
  default     = false
  description = "A boolean flag to enable/disable DNS support in the VPC. Defaults to true"
}

variable "enable_dns_hostnames" {
  type        = bool
  default     = false
  description = "A boolean flag to enable/disable DNS hostnames in the VPC. Defaults false"
}

variable "public_subnets" {
  type        = list(map(string))
  default     = []
  description = "A list of public subnets and azs"
}

variable "private_subnets" {
  type        = list(map(string))
  default     = []
  description = "A list of private subnets and azs"
}

variable "map_public_ip_on_launch" {
  type        = bool
  default     = false
  description = "Specify true to indicate that instances launched into the subnet should be assigned a public IP address. Default is false"
}

variable "create_nat_gateway" {
  type        = bool
  default     = false
  description = "Controls if an NAT Gateway will be created or not. If true we also create one Elastic IP for each NAT instance"
}

variable "eks_public_subnet_tags" {
  type        = map(string)
  default     = {}
  description = "Add extra tags for EKS elbs"
}

variable "eks_private_subnet_tags" {
  type        = map(string)
  default     = {}
  description = "Add extra tags for EKS elbs"
}