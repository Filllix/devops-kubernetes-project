locals {
  eks_oidc_issuer = replace(
    aws_eks_cluster.main.identity[0].oidc[0].issuer,
    "https://",
    ""
  )
}

resource "aws_iam_policy" "alb_controller" {
  provider = aws.iam_global

  name        = "${var.project_name}-AWSLoadBalancerControllerIAMPolicy"
  description = "IAM policy for AWS Load Balancer Controller"

  policy = file("${path.module}/alb-controller-iam-policy.json")

  tags = {
    Project     = var.project_name
    Environment = var.environment
  }
}

resource "aws_iam_role" "alb_controller" {
  provider = aws.iam_global

  name = "${var.project_name}-alb-controller-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Federated = aws_iam_openid_connect_provider.eks.arn
        }

        Action = "sts:AssumeRoleWithWebIdentity"

        Condition = {
          StringEquals = {
            "${local.eks_oidc_issuer}:aud" = "sts.amazonaws.com"

            "${local.eks_oidc_issuer}:sub" = "system:serviceaccount:kube-system:aws-load-balancer-controller"
          }
        }
      }
    ]
  })

  tags = {
    Project     = var.project_name
    Environment = var.environment
  }
}

resource "aws_iam_role_policy_attachment" "alb_controller" {
  provider = aws.iam_global

  role       = aws_iam_role.alb_controller.name
  policy_arn = aws_iam_policy.alb_controller.arn
}