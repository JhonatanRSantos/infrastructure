module "security-group" {
  count  = var.create_sg ? 1 : 0
  source = "terraform-aws-modules/security-group/aws"

  name                     = var.name
  vpc_id                   = var.vpc_id
  ingress_with_cidr_blocks = var.ingress_with_cidr_blocks
  egress_with_cidr_blocks  = var.egress_with_cidr_blocks
  tags                     = var.tags
}