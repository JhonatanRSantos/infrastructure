resource "aws_iam_group" "iam_read_only_group" {
  name = "ReadOnly"
  path = "/read-only/"
}

resource "aws_iam_policy" "iam_eks_read_only_policy" {
  name = "ReadOnlyPoliceEKS"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "eks:ListFargateProfiles",
          "eks:DescribeNodegroup",
          "eks:ListNodegroups",
          "eks:DescribeFargateProfile",
          "eks:ListTagsForResource",
          "eks:ListUpdates",
          "eks:DescribeUpdate",
          "eks:DescribeCluster",
          "eks:ListClusters",
          "eks:AccessKubernetesApi",
          "eks:GetParameter"
        ],
        "Resource" : "*"
      }
    ]
  })
}

resource "aws_iam_group_policy_attachment" "iam_eks_read_only_policy" {
  group      = aws_iam_group.iam_read_only_group.name
  policy_arn = aws_iam_policy.iam_eks_read_only_policy.arn
}

resource "aws_iam_user" "iam_user_developer" {
  name = "developer"
}

resource "aws_iam_group_membership" "iam_group_membership_read_only" {
  name = "ReadOnly"
  users = [
    aws_iam_user.iam_user_developer.name
  ]
  group = aws_iam_group.iam_read_only_group.name
}