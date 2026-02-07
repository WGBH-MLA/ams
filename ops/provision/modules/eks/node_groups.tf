# EKS Node Groups
# Adapted from notch8-ops terraform

resource "aws_launch_template" "eks_nodes" {
  count = var.create_eks_cluster ? 1 : 0
  
  name_prefix   = "${var.cluster_name}-eks-node-"
  instance_type = var.node_instance_type

  # EKS bootstrap user data
  user_data = base64encode(templatefile("${path.module}/user_data.tpl", {
    cluster_name     = aws_eks_cluster.main[0].name
    cluster_endpoint = aws_eks_cluster.main[0].endpoint
    cluster_ca       = aws_eks_cluster.main[0].certificate_authority[0].data
  }))

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name        = "${var.cluster_name}-node"
      ManagedBy   = "terraform"
      Environment = var.namespace
      Cluster     = var.cluster_name
    }
  }

  tag_specifications {
    resource_type = "volume"
    tags = {
      Name        = "${var.cluster_name}-node-volume"
      ManagedBy   = "terraform"
      Environment = var.namespace
    }
  }
}

resource "aws_eks_node_group" "main" {
  count = var.create_eks_cluster ? 1 : 0
  
  version              = var.k8s_version
  force_update_version = true
  cluster_name         = aws_eks_cluster.main[0].name
  node_group_name      = "${var.namespace}-ng"
  node_role_arn        = aws_iam_role.eks_node[0].arn
  subnet_ids           = var.private_subnets

  scaling_config {
    desired_size = var.desired_size
    max_size     = var.max_size
    min_size     = var.min_size
  }

  # Launch template
  launch_template {
    id      = aws_launch_template.eks_nodes[0].id
    version = "$Latest"
  }

  # Node labels
  labels = {
    "node.kubernetes.io/instance-type" = var.node_instance_type
    "Environment"                       = var.namespace
    "ManagedBy"                         = "terraform"
  }

  tags = {
    Environment = var.namespace
    Cluster     = var.cluster_name
    ManagedBy   = "terraform"
  }

  # Don't recreate node group on every launch template change
  lifecycle {
    ignore_changes = [
      scaling_config,
      launch_template[0].version
    ]
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_node_worker_policy[0],
    aws_iam_role_policy_attachment.eks_node_ecr_policy[0],
    aws_iam_role_policy_attachment.eks_node_cni_policy[0],
  ]
}
