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
  value       = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  description = "Endpoint for EKS cluster"
  value       = module.eks.cluster_endpoint
  sensitive   = true
}

output "eks_cluster_version" {
  description = "Kubernetes version of the EKS cluster"
  value       = module.eks.cluster_version
}

output "eks_cluster_certificate_authority" {
  description = "EKS cluster certificate authority data"
  value       = module.eks.cluster_ca_data
  sensitive   = true
}

# GitHub Actions
output "github_actions_role_arn" {
  description = "IAM role ARN for GitHub Actions to assume via OIDC"
  value       = module.eks.github_actions_role_arn
}

output "efs_id" {
  description = "EFS file system ID"
  value       = module.eks.efs_id
}

output "efs_dns_name" {
  description = "EFS file system DNS name"
  value       = module.eks.efs_dns_name
}

# Rancher
output "rancher_url" {
  description = "URL for Rancher UI"
  value       = var.enable_rancher ? "https://${var.rancher_hostname}" : null
}
