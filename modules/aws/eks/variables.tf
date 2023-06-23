variable "environment" {
  type        = string
  description = "Current environment name"
}

variable "create" {
  type        = bool
  default     = true
  description = "Controls if cluster should be created"
}

variable "account_id" {
  type        = number
  description = "AWS account ID"
}

variable "cluster_version" {
  type        = string
  default     = "1.26"
  description = "Current EKS cluster version"
}

variable "name" {
  type        = string
  description = "Name of the EKS cluster"
}

variable "endpoint_public_access" {
  type        = bool
  default     = true
  description = "Indicates whether or not the Amazon EKS public API server endpoint is enabled"
}

variable "endpoint_private_access" {
  type        = bool
  default     = false
  description = "Indicates whether or not the Amazon EKS private API server endpoint is enabled. Must be True to use with VPN"
}

variable "subnet_ids" {
  type        = list(string)
  description = "A list of all subnets EKS must work with"
}

variable "node_group_subnet_ids" {
  type        = list(string)
  description = "A list of subnet IDs where the nodes/node groups will be provisioned"
}

variable "node_group_scaling_config" {
  type = object({
    min_size     = number
    max_size     = number
    desired_size = number
  })
  default = {
    min_size     = 1
    max_size     = 1
    desired_size = 1
  }
  description = "Configuration block with scaling settings"
}

variable "node_ami_type" {
  type = string
  # https://docs.aws.amazon.com/pt_br/eks/latest/APIReference/API_Nodegroup.html
  default     = "AL2_x86_64"
  description = "Type of Amazon Machine Image (AMI) associated with the EKS Node Group"
}

variable "node_capacity_type" {
  type    = string
  default = "ON_DEMAND"

  validation {
    condition     = contains(["ON_DEMAND", "SPOT"], var.node_capacity_type)
    error_message = "Cluster node group capacity supports only: ON_DEMAND, SPOT"
  }
}

variable "node_disk_size" {
  type        = number
  default     = 20
  description = "Disk size in GiB for worker nodes"
}

variable "node_instance_types" {
  type        = list(string)
  default     = ["t2.micro"]
  description = "List of instance types associated with the EKS Node Group"
}

# variable "read_only_user_arn" {
#   type = string
# }

# variable "read_only_user_name" {
#   type = string
# }