# EFS File System for AMS
# Adapted from notch8-ops terraform

resource "aws_security_group" "efs" {
  count = var.create_eks_cluster && var.create_efs ? 1 : 0
  
  name        = "${var.cluster_name}-efs-sg"
  description = "Security group for EFS mount targets"
  vpc_id      = module.networking.vpc.vpc_id

  tags = {
    Name        = "${var.cluster_name}-efs-sg"
    ManagedBy   = "terraform"
    Environment = var.namespace
  }
}

resource "aws_vpc_security_group_ingress_rule" "efs_nfs" {
  count = var.create_eks_cluster && var.create_efs ? 1 : 0
  
  security_group_id = aws_security_group.efs[0].id
  cidr_ipv4         = module.networking.vpc.vpc_cidr_block
  description       = "Allow NFS traffic from VPC"
  from_port         = 2049
  to_port           = 2049
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "efs_egress" {
  count = var.create_eks_cluster && var.create_efs ? 1 : 0
  
  security_group_id = aws_security_group.efs[0].id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_efs_file_system" "main" {
  count = var.create_eks_cluster && var.create_efs ? 1 : 0
  
  creation_token   = "${var.cluster_name}-efs"
  performance_mode = "generalPurpose"
  throughput_mode  = "bursting"
  encrypted        = true

  tags = {
    Name        = "${var.cluster_name}-efs"
    ManagedBy   = "terraform"
    Environment = var.namespace
  }

  lifecycle {
    prevent_destroy = true
  }
}

# Mount targets in all private subnets
resource "aws_efs_mount_target" "main" {
  count = var.create_eks_cluster && var.create_efs ? 3 : 0  # 3 private subnets defined in vpc.tf
  
  file_system_id  = aws_efs_file_system.main[0].id
  security_groups = [aws_security_group.efs[0].id]
  subnet_id       = module.networking.vpc.private_subnets[count.index]

  lifecycle {
    create_before_destroy = true
  }
}
