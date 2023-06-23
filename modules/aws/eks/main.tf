# Create K8S Service Role and Policies
resource "aws_iam_role" "service_role_eks_cluster" {
  count = var.create ? 1 : 0

  name                 = "ServiceRoleForEKSCluster${title(var.name)}${title(var.environment)}"
  description          = "Manage all services roles for ${var.environment} EKS"
  max_session_duration = 43200 // 12 hours

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "eks.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "amazon_eks_cluster_policy" {
  count = var.create ? 1 : 0

  role = aws_iam_role.service_role_eks_cluster.*.name[0]
  # https://github.com/SummitRoute/aws_managed_policies/blob/master/policies/AmazonEKSClusterPolicy
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_role_policy_attachment" "amazon_eks_service_policy" {
  count = var.create ? 1 : 0

  role = aws_iam_role.service_role_eks_cluster.*.name[0]
  # https://github.com/SummitRoute/aws_managed_policies/blob/master/policies/AmazonEKSServicePolicy
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
}

resource "aws_iam_role_policy_attachment" "amazon_eks_vpc_resource_controller" {
  count = var.create ? 1 : 0

  role = aws_iam_role.service_role_eks_cluster.*.name[0]
  # https://github.com/SummitRoute/aws_managed_policies/blob/master/policies/AmazonEKSVPCResourceController
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
}

# Create K8S Cluster
resource "aws_eks_cluster" "eks_cluster" {
  count = var.create ? 1 : 0

  name     = "${var.name}-${var.environment}"
  version  = var.cluster_version
  role_arn = aws_iam_role.service_role_eks_cluster.*.arn[0]

  vpc_config {
    # Must be true to be used with a VPN
    endpoint_private_access = var.endpoint_private_access
    endpoint_public_access  = var.endpoint_public_access

    # TODO: Security group
    subnet_ids = var.subnet_ids
  }

  depends_on = [
    aws_iam_role.service_role_eks_cluster,
    aws_iam_role_policy_attachment.amazon_eks_cluster_policy,
    aws_iam_role_policy_attachment.amazon_eks_service_policy,
    aws_iam_role_policy_attachment.amazon_eks_vpc_resource_controller
  ]
}

# Create Node Groups Service Role
resource "aws_iam_role" "service_role_eks_node_group" {
  count = var.create ? 1 : 0

  name                 = "ServiceRoleForEKSClusterNodeGroup${title(var.name)}${title(var.environment)}"
  description          = "Manage all Node Groups for ${var.environment} EKS"
  max_session_duration = 43200 // 12 hours

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "ec2.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "amazon_eks_worker_node" {
  count = var.create ? 1 : 0

  role = aws_iam_role.service_role_eks_node_group.*.name[0]
  # https://github.com/SummitRoute/aws_managed_policies/blob/master/policies/AmazonEKSWorkerNodePolicy
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "amazon_eks_cni" {
  count = var.create ? 1 : 0

  role = aws_iam_role.service_role_eks_node_group.*.name[0]
  # https://github.com/SummitRoute/aws_managed_policies/blob/master/policies/AmazonEKS_CNI_Policy
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "amazon_ec2_container_registry_read_only" {
  count = var.create ? 1 : 0

  role = aws_iam_role.service_role_eks_node_group.*.name[0]
  # https://github.com/SummitRoute/aws_managed_policies/blob/master/policies/AmazonEC2ContainerRegistryReadOnly
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_role_policy_attachment" "amazon_ec2_full_access" {
  count = var.create ? 1 : 0

  role = aws_iam_role.service_role_eks_node_group.*.name[0]
  # https://github.com/SummitRoute/aws_managed_policies/blob/master/policies/AmazonEC2FullAccess
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
}

# Create Node Groups
resource "aws_eks_node_group" "node_group" {
  count = var.create ? 1 : 0

  version         = var.cluster_version
  subnet_ids      = var.node_group_subnet_ids
  cluster_name    = aws_eks_cluster.eks_cluster.*.name[0]
  node_role_arn   = aws_iam_role.service_role_eks_node_group.*.arn[0]
  node_group_name = "${var.name}-${var.environment}-main"

  scaling_config {
    min_size     = var.node_group_scaling_config.min_size
    max_size     = var.node_group_scaling_config.max_size
    desired_size = var.node_group_scaling_config.desired_size
  }

  ami_type       = var.node_ami_type
  disk_size      = var.node_disk_size
  capacity_type  = var.node_capacity_type
  instance_types = var.node_instance_types

  depends_on = [
    aws_iam_role.service_role_eks_node_group,
    aws_iam_role_policy_attachment.amazon_eks_cni,
    aws_iam_role_policy_attachment.amazon_eks_worker_node,
    aws_iam_role_policy_attachment.amazon_ec2_container_registry_read_only
  ]
}

# Config K8S cluster 
data "aws_eks_cluster_auth" "eks_cluster_auth_information" {
  name = aws_eks_cluster.eks_cluster.*.name[0]

  depends_on = [
    aws_eks_cluster.eks_cluster,
    aws_eks_node_group.node_group
  ]
}

provider "kubernetes" {
  host                   = aws_eks_cluster.eks_cluster.*.endpoint[0]
  token                  = data.aws_eks_cluster_auth.eks_cluster_auth_information.token
  cluster_ca_certificate = base64decode(aws_eks_cluster.eks_cluster.*.certificate_authority[0][0].data)
}


resource "kubernetes_cluster_role" "cluster_role_read_only" {
  metadata {
    name = "read-only"
  }

  rule {
    api_groups = [""]
    resources = [
      "deployments",
      "pods",
      "pods/log",
      "configmaps",
      "secrets",
      "services",
      "virtualservices",
      "horizontalpodautoscalers",
      "gateways",
      "namespaces"
    ]
    verbs = ["get", "list", "watch"]
  }
}

resource "kubernetes_cluster_role_binding" "cluster_role_read_only_binding" {
  metadata {
    name = "read-only-bind"
  }

  subject {
    kind      = "Group"
    name      = "read-only-group"
    api_group = "rbac.authorization.k8s.io"
  }

  role_ref {
    kind      = "ClusterRole"
    name      = "read-only"
    api_group = "rbac.authorization.k8s.io"
  }
}

# resource "kubernetes_config_map_v1_data" "aws-auth" {
#   data = {
#     "mapRoles" = <<EOF
#         - groups:
#             - system:bootstrappers
#             - system:nodes
#             rolearn: arn:aws:iam::${var.account_id}:role/ServiceRoleForEKSClusterNodeGroup${title(var.name)}${title(var.environment)}
#             username: system:node:{{EC2PrivateDNSName}}
#     EOF
#     "mapUsers" = <<EOF
#         - userarn: arn:aws:iam::${var.account_id}:root
#             groups:
#               - system:masters
#     EOF   
#   }

#   force = true
#   metadata {
#     name      = "aws-auth"
#     namespace = "kube-system"
#   }
# }