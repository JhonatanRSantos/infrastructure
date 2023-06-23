####################
#       VPC        #
####################

resource "aws_vpc" "vpc" {
  count = var.create_vpc ? 1 : 0

  cidr_block           = var.cidr_block
  enable_dns_support   = var.enable_dns_support   # Required for EKS.
  enable_dns_hostnames = var.enable_dns_hostnames # Required for EKS.

  tags = {
    Name         = "${var.name}-${var.environment}"
    Terraform    = true
    Environment  = var.environment
    ResourceType = "aws_vpc"
  }
}

####################
# INTERNET GATEWAY #
####################

resource "aws_internet_gateway" "internet_gateway" {
  count  = var.create_vpc ? 1 : 0
  vpc_id = aws_vpc.vpc.*.id[0]

  tags = {
    Name         = "${var.name}-${var.environment}"
    Terraform    = true
    Environment  = var.environment
    ResourceType = "aws_internet_gateway"
  }
}

####################
#     SUB NETS     #
####################

resource "aws_subnet" "public_subnets" {
  count = var.create_vpc && length(var.public_subnets) > 0 ? length(var.public_subnets) : 0

  vpc_id                  = aws_vpc.vpc.*.id[0]
  cidr_block              = var.public_subnets[count.index].cidr_block
  availability_zone       = var.public_subnets[count.index].az
  map_public_ip_on_launch = var.map_public_ip_on_launch # Required for EKS

  tags = merge(
    {
      Name         = "${var.name}-${var.environment}-public-${count.index + 1}"
      Terraform    = true
      Environment  = var.environment
      ResourceType = "aws_subnet"
    },
    var.eks_public_subnet_tags
  )
}

resource "aws_subnet" "private_subnets" {
  count = var.create_vpc && length(var.private_subnets) > 0 ? length(var.private_subnets) : 0

  vpc_id            = aws_vpc.vpc.*.id[0]
  cidr_block        = var.private_subnets[count.index].cidr_block
  availability_zone = var.private_subnets[count.index].az

  tags = merge(
    {
      Name         = "${var.name}-${var.environment}-private-${count.index + 1}"
      Terraform    = true
      Environment  = var.environment
      ResourceType = "aws_subnet"
    },
    var.eks_private_subnet_tags
  )
}

####################
#    ELASTICIP     #
####################

# For billing details
# https://aws.amazon.com/pt/ec2/pricing/on-demand/
# No charges will be applied if the ip is associated with a running instance, only if it is not being used there will be charges.
resource "aws_eip" "eip" {
  count = var.create_vpc && var.create_nat_gateway && length(var.public_subnets) > 0 ? length(var.public_subnets) : 0

  tags = {
    Name         = "${var.name}-${var.environment}-${count.index + 1}"
    Terraform    = true
    Environment  = var.environment
    ResourceType = "aws_eip"
  }

  depends_on = [aws_internet_gateway.internet_gateway]
}

####################
#    NAT GATEWAY   #
####################

resource "aws_nat_gateway" "nat_gateway" {
  count = var.create_vpc && var.create_nat_gateway && length(var.public_subnets) > 0 ? length(var.public_subnets) : 0

  subnet_id     = aws_subnet.public_subnets.*.id[count.index]
  allocation_id = aws_eip.eip.*.id[count.index]

  tags = {
    Name         = "${var.name}-${var.environment}-public-${count.index + 1}"
    Terraform    = true
    Environment  = var.environment
    ResourceType = "nat_gateway"
  }
}

####################
#   ROUTE TABLES   #
####################

resource "aws_default_route_table" "default_route_table" {
  count = var.create_vpc ? 1 : 0

  default_route_table_id = aws_vpc.vpc.*.default_route_table_id[0]

  tags = {
    Name         = "${var.name}-${var.environment}-default"
    Terraform    = true
    Environment  = var.environment
    ResourceType = "aws_route_table"
  }
}

resource "aws_route_table" "public_route_table" {
  count = var.create_vpc && length(var.public_subnets) > 0 && length(aws_internet_gateway.internet_gateway) > 0 ? 1 : 0

  vpc_id = aws_vpc.vpc.*.id[0]
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.*.id[0]
  }

  tags = {
    Name         = "${var.name}-${var.environment}-public"
    Terraform    = true
    Environment  = var.environment
    ResourceType = "aws_route_table"
  }
}

resource "aws_route_table" "private_route_table" {
  count = var.create_vpc && length(var.private_subnets) > 0 && length(aws_nat_gateway.nat_gateway) > 0 ? length(aws_nat_gateway.nat_gateway) : 0

  vpc_id = aws_vpc.vpc.*.id[0]
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat_gateway.*.id[count.index]
  }

  tags = {
    Name         = "${var.name}-${var.environment}-private-${count.index + 1}"
    Terraform    = true
    Environment  = var.environment
    ResourceType = "aws_route_table"
  }
}

resource "aws_route_table_association" "public_route_table_association" {
  count = var.create_vpc && length(aws_subnet.public_subnets) > 0 && length(aws_route_table.public_route_table) > 0 ? length(aws_subnet.public_subnets) : 0

  subnet_id      = aws_subnet.public_subnets.*.id[count.index]
  route_table_id = aws_route_table.public_route_table.*.id[0]
}

resource "aws_route_table_association" "private_route_table_association" {
  count = var.create_vpc && length(aws_subnet.private_subnets) > 0 && length(aws_route_table.private_route_table) > 0 ? length(aws_route_table.private_route_table) : 0

  subnet_id      = aws_subnet.private_subnets.*.id[count.index]
  route_table_id = aws_route_table.private_route_table.*.id[count.index]
}