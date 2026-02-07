# EKS Add-ons (EBS and EFS CSI Drivers)
# Simplified version adapted from notch8-ops

# EBS CSI Driver Add-on
resource "aws_eks_addon" "ebs_csi_driver" {
  count = var.create_eks_cluster ? 1 : 0
  
  cluster_name                = aws_eks_cluster.main[0].name
  addon_name                  = "aws-ebs-csi-driver"
  addon_version               = "v1.55.0-eksbuild.1"  # Check for latest: aws eks describe-addon-versions --addon-name aws-ebs-csi-driver
  service_account_role_arn    = aws_iam_role.ebs_csi_driver[0].arn
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"

  tags = {
    Name        = "${var.cluster_name}-ebs-csi-driver"
    ManagedBy   = "terraform"
    Environment = var.namespace
  }
}

# EFS CSI Driver Add-on
resource "aws_eks_addon" "efs_csi_driver" {
  count = var.create_eks_cluster ? 1 : 0
  
  cluster_name                = aws_eks_cluster.main[0].name
  addon_name                  = "aws-efs-csi-driver"
  addon_version               = "v2.3.0-eksbuild.1"  # Check for latest: aws eks describe-addon-versions --addon-name aws-efs-csi-driver
  service_account_role_arn    = aws_iam_role.efs_csi_driver[0].arn
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"

  tags = {
    Name        = "${var.cluster_name}-efs-csi-driver"
    ManagedBy   = "terraform"
    Environment = var.namespace
  }
}

# VPC CNI Add-on (networking)
resource "aws_eks_addon" "vpc_cni" {
  count = var.create_eks_cluster ? 1 : 0
  
  cluster_name             = aws_eks_cluster.main[0].name
  addon_name               = "vpc-cni"
  addon_version            = "v1.21.1-eksbuild.3"  # Check for latest: aws eks describe-addon-versions --addon-name vpc-cni
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "PRESERVE"

  tags = {
    Name        = "${var.cluster_name}-vpc-cni"
    ManagedBy   = "terraform"
    Environment = var.namespace
  }
}

# CoreDNS Add-on
resource "aws_eks_addon" "coredns" {
  count = var.create_eks_cluster ? 1 : 0
  
  cluster_name             = aws_eks_cluster.main[0].name
  addon_name               = "coredns"
  addon_version            = "v1.13.2-eksbuild.1"  # Check for latest: aws eks describe-addon-versions --addon-name coredns
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "PRESERVE"

  tags = {
    Name        = "${var.cluster_name}-coredns"
    ManagedBy   = "terraform"
    Environment = var.namespace
  }

  depends_on = [
    aws_eks_node_group.main
  ]
}

# Kube-proxy Add-on
resource "aws_eks_addon" "kube_proxy" {
  count = var.create_eks_cluster ? 1 : 0
  
  cluster_name             = aws_eks_cluster.main[0].name
  addon_name               = "kube-proxy"
  addon_version            = "v1.34.3-eksbuild.2"  # Check for latest: aws eks describe-addon-versions --addon-name kube-proxy
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "PRESERVE"

  tags = {
    Name        = "${var.cluster_name}-kube-proxy"
    ManagedBy   = "terraform"
    Environment = var.namespace
  }
}
