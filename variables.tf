variable "environment" {
  type        = string
  description = "Deployment environment"

  validation {
    condition     = length(trimspace(var.environment)) > 0
    error_message = "All deployments must have a environment"
  }
}

variable "account_id" {
  type        = number
  description = "AWS account ID"
}

# VPC configs

variable "vpc_create" {
  type = bool
}

variable "vpc_name" {
  type = string
}

variable "vpc_cidr_block" {
  type = string
}

variable "vpc_public_subnets" {
  type = list(map(string))
}

variable "vpc_private_subnets" {
  type = list(map(string))
}

variable "vpc_map_public_ip_on_launch" {
  type    = bool
  default = true
}

variable "vpc_enable_dns_support" {
  type    = bool
  default = true
}

variable "vpc_enable_dns_hostnames" {
  type    = bool
  default = true
}

variable "vpc_create_nat_gateway" {
  type    = bool
  default = true
}

variable "eks_create" {
  type = bool
}

variable "eks_name" {
  type = string
}

variable "eks_node_group_scaling_config" {
  type = object({
    min_size     = number
    max_size     = number
    desired_size = number
  })
}