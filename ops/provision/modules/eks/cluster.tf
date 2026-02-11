# EKS Cluster Creation
# Adapted from notch8-ops terraform for AMS project

resource "aws_eks_cluster" "main" {
  count = var.create_eks_cluster ? 1 : 0
  
  name     = var.cluster_name
  role_arn = aws_iam_role.eks_cluster[0].arn
  version  = var.k8s_version

  vpc_config {
    subnet_ids = concat(
      var.private_subnets,
      var.public_subnets
    )
    endpoint_private_access = true
    endpoint_public_access  = true
    # Optionally restrict public access to specific CIDRs
    # public_access_cidrs = ["YOUR_IP/32"]
    
    # Security group for cluster communication
    security_group_ids = []
  }

  access_config {
    authentication_mode = "API_AND_CONFIG_MAP"
  }

  # Enable encryption at rest for secrets
  encryption_config {
    provider {
      key_arn = aws_kms_key.eks[0].arn
    }
    resources = ["secrets"]
  }

  # Enable all cluster logging for audit and security
  enabled_cluster_log_types = [
    "api",
    "audit",
    "authenticator",
    "controllerManager",
    "scheduler"
  ]

  lifecycle {
    ignore_changes = [access_config]
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy[0],
    aws_cloudwatch_log_group.eks[0]
  ]

  tags = {
    Name        = var.cluster_name
    ManagedBy   = "terraform"
    Environment = var.namespace
  }
}

# KMS Key for EKS encryption
resource "aws_kms_key" "eks" {
  count = var.create_eks_cluster ? 1 : 0
  
  description             = "EKS Secret Encryption Key for ${var.cluster_name}"
  deletion_window_in_days = 10
  enable_key_rotation     = true

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "Enable IAM User Permissions"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "Allow EKS to use the key"
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
        Action = [
          "kms:Decrypt",
          "kms:DescribeKey",
          "kms:CreateGrant"
        ]
        Resource = "*"
      }
    ]
  })

  tags = {
    Name        = "${var.cluster_name}-eks-encryption"
    ManagedBy   = "terraform"
    Environment = var.namespace
  }
}

resource "aws_kms_alias" "eks" {
  count = var.create_eks_cluster ? 1 : 0
  
  name          = "alias/${var.cluster_name}-eks"
  target_key_id = aws_kms_key.eks[0].key_id
}

# CloudWatch Log Group for EKS logs
resource "aws_cloudwatch_log_group" "eks" {
  count = var.create_eks_cluster ? 1 : 0
  
  name              = "/aws/eks/${var.cluster_name}/cluster"
  retention_in_days = 30

  tags = {
    Name        = "${var.cluster_name}-eks-logs"
    ManagedBy   = "terraform"
    Environment = var.namespace
  }
}

# OIDC Provider for IRSA (IAM Roles for Service Accounts)
resource "aws_iam_openid_connect_provider" "eks" {
  count = var.create_eks_cluster ? 1 : 0
  
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks[0].certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.main[0].identity[0].oidc[0].issuer

  tags = {
    Name        = "${var.cluster_name}-eks-irsa"
    ManagedBy   = "terraform"
    Environment = var.namespace
  }
}

data "tls_certificate" "eks" {
  count = var.create_eks_cluster ? 1 : 0
  url   = aws_eks_cluster.main[0].identity[0].oidc[0].issuer
}

# Local value for OIDC provider ARN (used by other resources)
locals {
  oidc_provider_arn = var.create_eks_cluster ? aws_iam_openid_connect_provider.eks[0].arn : ""
  oidc_hostpath     = var.create_eks_cluster ? replace(aws_eks_cluster.main[0].identity[0].oidc[0].issuer, "https://", "") : ""
}
