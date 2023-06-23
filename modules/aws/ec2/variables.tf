variable "create_ec2" {
  type        = bool
  default     = true
  description = "Controls if EC2 should be created"
}

variable "name" {
  type        = string
  description = "EC2 identifier"

  validation {
    condition     = length(trimspace(var.name)) > 3
    error_message = "All EC2 must have a valid name"
  }
}

variable "subnet_id" {
  type        = string
  description = "The VPC Subnet ID to launch in"

  validation {
    condition     = trimspace(var.subnet_id) != ""
    error_message = "All EC2 must have a valid network associated with it"
  }
}

variable "instance_type" {
  type        = string
  default     = "t2.micro"
  description = "The type of instance to start"
}

variable "vpc_security_group_ids" {
  type        = list(string)
  description = "A list of security group IDs to associate with"
}

variable "associate_public_ip_address" {
  type        = bool
  default     = true
  description = "Whether to associate a public IP address with an instance in a VPC"
}

variable "tags" {
  type        = map(string)
  description = "A mapping of tags to assign to the resource"
}