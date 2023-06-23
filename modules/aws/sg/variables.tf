variable "create_sg" {
  type        = bool
  default     = true
  description = "Controls if Secutiry Group should be created"
}

variable "name" {
  type        = string
  description = "Secutiry Group name"

  validation {
    condition     = length(trimspace(var.name)) > 0
    error_message = "All security groups must have a valid name"
  }
}

variable "vpc_id" {
  type    = string
  default = "ID of the VPC where to create security group"
}

variable "ingress_with_cidr_blocks" {
  type = list(map(string))
  default = [
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port   = -1
      to_port     = -1
      protocol    = "icmp"
      cidr_blocks = "0.0.0.0/0"
    },
  ]
  description = "List of ingress rules to create where 'cidr_blocks' is used"
}

variable "egress_with_cidr_blocks" {
  type = list(map(string))
  default = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      description = "All traffic"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
  description = "List of egress rules to create where 'cidr_blocks' is used"
}

variable "tags" {
  type        = map(string)
  description = "A mapping of tags to assign to security group"
}