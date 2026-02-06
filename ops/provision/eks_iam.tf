# IAM Roles for EKS Cluster and Nodes
# Adapted from notch8-ops terraform

# EKS Cluster IAM Role
resource "aws_iam_role" "eks_cluster" {
  count = var.create_eks_cluster ? 1 : 0
  
  name = "${var.cluster_name}-eks-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = ["sts:AssumeRole", "sts:TagSession"]
        Effect    = "Allow"
        Principal = { Service = "eks.amazonaws.com" }
      }
    ]
  })

  tags = {
    Name        = "${var.cluster_name}-eks-cluster-role"
    ManagedBy   = "terraform"
    Environment = var.namespace
  }
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  count = var.create_eks_cluster ? 1 : 0
  
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster[0].name
}

# EKS Node IAM Role
resource "aws_iam_role" "eks_node" {
  count = var.create_eks_cluster ? 1 : 0
  
  name = "${var.cluster_name}-eks-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })

  tags = {
    Name        = "${var.cluster_name}-eks-node-role"
    ManagedBy   = "terraform"
    Environment = var.namespace
  }
}

# Attach required policies to node role
resource "aws_iam_role_policy_attachment" "eks_node_worker_policy" {
  count = var.create_eks_cluster ? 1 : 0
  
  role       = aws_iam_role.eks_node[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "eks_node_ecr_policy" {
  count = var.create_eks_cluster ? 1 : 0
  
  role       = aws_iam_role.eks_node[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_role_policy_attachment" "eks_node_cni_policy" {
  count = var.create_eks_cluster ? 1 : 0
  
  role       = aws_iam_role.eks_node[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

# ── IRSA role for EBS CSI Driver ──
resource "aws_iam_role" "ebs_csi_driver" {
  count = var.create_eks_cluster ? 1 : 0

  name = "${var.cluster_name}-ebs-csi-driver-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Federated = local.oidc_provider_arn
      }
      Action = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "${local.oidc_hostpath}:aud" = "sts.amazonaws.com"
          "${local.oidc_hostpath}:sub" = "system:serviceaccount:kube-system:ebs-csi-controller-sa"
        }
      }
    }]
  })

  tags = {
    Name        = "${var.cluster_name}-ebs-csi-driver-role"
    ManagedBy   = "terraform"
    Environment = var.namespace
  }
}

resource "aws_iam_role_policy_attachment" "ebs_csi_driver" {
  count = var.create_eks_cluster ? 1 : 0

  role       = aws_iam_role.ebs_csi_driver[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}

# ── IRSA role for EFS CSI Driver ──
resource "aws_iam_role" "efs_csi_driver" {
  count = var.create_eks_cluster ? 1 : 0

  name = "${var.cluster_name}-efs-csi-driver-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Federated = local.oidc_provider_arn
      }
      Action = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "${local.oidc_hostpath}:aud" = "sts.amazonaws.com"
          "${local.oidc_hostpath}:sub" = "system:serviceaccount:kube-system:efs-csi-controller-sa"
        }
      }
    }]
  })

  tags = {
    Name        = "${var.cluster_name}-efs-csi-driver-role"
    ManagedBy   = "terraform"
    Environment = var.namespace
  }
}

resource "aws_iam_role_policy_attachment" "efs_csi_driver" {
  count = var.create_eks_cluster ? 1 : 0

  role       = aws_iam_role.efs_csi_driver[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEFSCSIDriverPolicy"
}

# ── GitHub Actions OIDC Federation (keyless auth for CI/CD) ──
resource "aws_iam_openid_connect_provider" "github" {
  count = var.create_eks_cluster ? 1 : 0

  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["ffffffffffffffffffffffffffffffffffffffff"]

  tags = {
    Name        = "github-actions-oidc"
    ManagedBy   = "terraform"
    Environment = var.namespace
  }
}

resource "aws_iam_role" "github_actions_deploy" {
  count = var.create_eks_cluster ? 1 : 0

  name = "${var.cluster_name}-github-actions-deploy"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Federated = aws_iam_openid_connect_provider.github[0].arn
      }
      Action = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
        }
        StringLike = {
          # Allow any branch/event from the WGBH-MLA/ams repo
          "token.actions.githubusercontent.com:sub" = "repo:WGBH-MLA/ams:*"
        }
      }
    }]
  })

  tags = {
    Name        = "${var.cluster_name}-github-actions-deploy"
    ManagedBy   = "terraform"
    Environment = var.namespace
  }
}

# Allow GitHub Actions role to describe/update kubeconfig for the cluster
resource "aws_iam_role_policy" "github_actions_eks" {
  count = var.create_eks_cluster ? 1 : 0

  name = "${var.cluster_name}-github-actions-eks"
  role = aws_iam_role.github_actions_deploy[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "EKSDescribe"
        Effect = "Allow"
        Action = [
          "eks:DescribeCluster",
          "eks:ListClusters"
        ]
        Resource = aws_eks_cluster.main[0].arn
      }
    ]
  })
}

# Grant GitHub Actions role cluster admin access via EKS access entry
resource "aws_eks_access_entry" "github_actions" {
  count = var.create_eks_cluster ? 1 : 0

  cluster_name  = aws_eks_cluster.main[0].name
  principal_arn = aws_iam_role.github_actions_deploy[0].arn
  type          = "STANDARD"

  tags = {
    Name        = "github-actions-deploy"
    ManagedBy   = "terraform"
    Environment = var.namespace
  }
}

resource "aws_eks_access_policy_association" "github_actions" {
  count = var.create_eks_cluster ? 1 : 0

  cluster_name  = aws_eks_cluster.main[0].name
  principal_arn = aws_iam_role.github_actions_deploy[0].arn
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

  access_scope {
    type = "cluster"
  }
}

# S3 access policy for nodes (to access AMS buckets)
# ── IRSA role for cert-manager (Route53 DNS-01 challenges) ──
resource "aws_iam_role" "cert_manager" {
  count = var.create_eks_cluster ? 1 : 0

  name = "${var.cluster_name}-cert-manager-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Federated = local.oidc_provider_arn
      }
      Action = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "${local.oidc_hostpath}:aud" = "sts.amazonaws.com"
          "${local.oidc_hostpath}:sub" = "system:serviceaccount:cert-manager:cert-manager"
        }
      }
    }]
  })

  tags = {
    Name        = "${var.cluster_name}-cert-manager-role"
    ManagedBy   = "terraform"
    Environment = var.namespace
  }
}

resource "aws_iam_role_policy" "cert_manager_route53" {
  count = var.create_eks_cluster ? 1 : 0

  name = "${var.cluster_name}-cert-manager-route53"
  role = aws_iam_role.cert_manager[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "Route53GetChange"
        Effect = "Allow"
        Action = "route53:GetChange"
        Resource = "arn:aws:route53:::change/*"
      },
      {
        Sid    = "Route53ChangeRecords"
        Effect = "Allow"
        Action = [
          "route53:ChangeResourceRecordSets",
          "route53:ListResourceRecordSets"
        ]
        Resource = "arn:aws:route53:::hostedzone/Z1NW9A2RAA74H1"
      },
      {
        Sid    = "Route53ListZones"
        Effect = "Allow"
        Action = "route53:ListHostedZonesByName"
        Resource = "*"
      }
    ]
  })
}

# S3 access policy for nodes (to access AMS buckets)
resource "aws_iam_role_policy" "eks_node_s3_policy" {
  count = var.create_eks_cluster ? 1 : 0
  
  name = "${var.cluster_name}-node-s3-policy"
  role = aws_iam_role.eks_node[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "S3Access"
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:PutObjectAcl",
          "s3:DeleteObject",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::ams-edge.wgbh-mla.org",
          "arn:aws:s3:::ams-edge.wgbh-mla.org/*",
          "arn:aws:s3:::${var.namespace}-ams-*",
          "arn:aws:s3:::${var.namespace}-ams-*/*"
        ]
      }
    ]
  })
}
