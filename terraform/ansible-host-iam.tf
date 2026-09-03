data "aws_iam_policy_document" "ansible_host_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "ansible_host" {
  provider = aws.iam_global

  name               = "${var.project_name}-ansible-host-role"
  assume_role_policy = data.aws_iam_policy_document.ansible_host_assume_role.json

  tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

data "aws_iam_policy_document" "ansible_host_eks" {
  statement {
    effect = "Allow"

    actions = [
      "eks:DescribeCluster"
    ]

    resources = [
      aws_eks_cluster.main.arn
    ]
  }
}

resource "aws_iam_role_policy" "ansible_host_eks" {
  provider = aws.iam_global

  name   = "${var.project_name}-ansible-host-eks-policy"
  role   = aws_iam_role.ansible_host.id
  policy = data.aws_iam_policy_document.ansible_host_eks.json
}

resource "aws_iam_instance_profile" "ansible_host" {
  provider = aws.iam_global

  name = "${var.project_name}-ansible-host-profile"
  role = aws_iam_role.ansible_host.name
}

resource "aws_eks_access_entry" "ansible_host" {
  cluster_name  = aws_eks_cluster.main.name
  principal_arn = aws_iam_role.ansible_host.arn
  type          = "STANDARD"
}

resource "aws_eks_access_policy_association" "ansible_host_admin" {
  cluster_name  = aws_eks_cluster.main.name
  principal_arn = aws_iam_role.ansible_host.arn

  policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

  access_scope {
    type = "cluster"
  }

  depends_on = [
    aws_eks_access_entry.ansible_host
  ]
}
