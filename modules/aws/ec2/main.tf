module "ec2" {
  count  = var.create_ec2 ? 1 : 0
  source = "terraform-aws-modules/ec2-instance/aws"

  name                        = var.name
  subnet_id                   = var.subnet_id
  instance_type               = var.instance_type
  vpc_security_group_ids      = var.vpc_security_group_ids
  associate_public_ip_address = var.associate_public_ip_address
  tags                        = var.tags
}