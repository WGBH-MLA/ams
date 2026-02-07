output "cluster_name" {
  description = "Name of the EKS cluster"
  value       = var.create_eks_cluster ? aws_eks_cluster.main[0].name : null
}

output "cluster_endpoint" {
  description = "Endpoint for EKS cluster"
  value       = var.create_eks_cluster ? aws_eks_cluster.main[0].endpoint : ""
  sensitive   = true
}

output "cluster_version" {
  description = "Kubernetes version of the EKS cluster"
  value       = var.create_eks_cluster ? aws_eks_cluster.main[0].version : null
}

output "cluster_ca_data" {
  description = "EKS cluster certificate authority data"
  value       = var.create_eks_cluster ? aws_eks_cluster.main[0].certificate_authority[0].data : ""
  sensitive   = true
}

output "github_actions_role_arn" {
  description = "IAM role ARN for GitHub Actions to assume via OIDC"
  value       = var.create_eks_cluster ? aws_iam_role.github_actions_deploy[0].arn : null
}

output "cert_manager_role_arn" {
  description = "IAM role ARN for cert-manager IRSA"
  value       = var.create_eks_cluster ? aws_iam_role.cert_manager[0].arn : ""
}

output "efs_id" {
  description = "EFS file system ID (created or existing)"
  value       = var.create_efs ? aws_efs_file_system.main[0].id : var.efs_name
}

output "efs_dns_name" {
  description = "EFS file system DNS name"
  value       = var.create_efs ? aws_efs_file_system.main[0].dns_name : null
}
