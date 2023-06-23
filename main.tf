# provider "aws" {
#   profile = "turing-bot"
#   region  = "us-east-1"
# }

terraform {
  required_version = "1.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.3.0"
    }
  }

  # This will be provided by backend.${environment}.hcl file
  backend "local" {}
}

module "users" {
  source = "./modules/aws/users"
}

module "vpc" {
  source = "./modules/aws/vpc"

  name                    = var.vpc_name
  create_vpc              = var.vpc_create
  cidr_block              = var.vpc_cidr_block
  environment             = var.environment
  public_subnets          = var.vpc_public_subnets
  private_subnets         = var.vpc_private_subnets
  create_nat_gateway      = var.vpc_create_nat_gateway
  enable_dns_support      = var.vpc_enable_dns_support
  enable_dns_hostnames    = var.vpc_enable_dns_hostnames
  map_public_ip_on_launch = var.vpc_map_public_ip_on_launch
  eks_public_subnet_tags = {
    # https://docs.aws.amazon.com/pt_br/eks/latest/userguide/network_reqs.html
    "kubernetes.io/cluster/${var.eks_name}-${var.environment}" = "shared" # Required for EKS
    "kubernetes.io/role/elb"                                   = 1        # Required for EKS
  }
  eks_private_subnet_tags = {
    # https://docs.aws.amazon.com/pt_br/eks/latest/userguide/network_reqs.html
    "kubernetes.io/cluster/${var.eks_name}-${var.environment}" = "shared" # Required for EKS
    "kubernetes.io/role/internal-elb"                          = 1        # Required for EKS
  }
}

module "eks" {
  source = "./modules/aws/eks"

  name        = var.eks_name
  create      = var.eks_create
  environment = var.environment

  account_id                = var.account_id
  node_group_scaling_config = var.eks_node_group_scaling_config
  subnet_ids                = length(module.vpc.private_subnets) > 0 ? split(",", join(",", concat(module.vpc.public_subnets, module.vpc.private_subnets))) : module.vpc.public_subnets
  node_group_subnet_ids     = module.vpc.public_subnets # module.vpc.private_subnets
}
