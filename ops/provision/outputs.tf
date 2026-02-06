output "fcrepo_prod_connection_string" {
  description = "Copy/Paste/Enter - You are in the matrix"
  sensitive   = true
  value = [
    for k, v in module.ec2.fcrepo_ips : "${k} ~ ssh -i ./ops/provision/${var.namespace}-key.pem ec2-user@${v}"
  ]
}

# EKS Cluster Outputs
output "eks_cluster_name" {
  description = "Name of the EKS cluster"
  value       = var.create_eks_cluster ? aws_eks_cluster.main[0].name : null
}

output "eks_cluster_endpoint" {
  description = "Endpoint for EKS cluster"
  value       = var.create_eks_cluster ? aws_eks_cluster.main[0].endpoint : null
  sensitive   = true
}

output "eks_cluster_version" {
  description = "Kubernetes version of the EKS cluster"
  value       = var.create_eks_cluster ? aws_eks_cluster.main[0].version : null
}

output "eks_cluster_certificate_authority" {
  description = "EKS cluster certificate authority data"
  value       = var.create_eks_cluster ? aws_eks_cluster.main[0].certificate_authority[0].data : null
  sensitive   = true
}

# GitHub Actions
output "github_actions_role_arn" {
  description = "IAM role ARN for GitHub Actions to assume via OIDC"
  value       = var.create_eks_cluster ? aws_iam_role.github_actions_deploy[0].arn : null
}

output "efs_id" {
  description = "EFS file system ID"
  value       = var.create_efs ? aws_efs_file_system.main[0].id : var.efs_name
}

output "efs_dns_name" {
  description = "EFS file system DNS name"
  value       = var.create_efs ? aws_efs_file_system.main[0].dns_name : null
}

# Rancher
output "rancher_url" {
  description = "URL for Rancher UI"
  value       = var.enable_rancher ? "https://${var.rancher_hostname}" : null
}

