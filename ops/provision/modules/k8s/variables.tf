variable "deploy_k8s_apps" {
  description = "Whether to deploy k8s apps. Set to true AFTER EKS cluster is created."
  type        = bool
  default     = false
}

variable "namespace" {
  type = string
}

variable "region" {
  default     = "us-east-1"
  description = "AWS region"
}

variable "kubeconfig" {
  type = string
  default = "kube_config.yaml"
  sensitive = true
}

variable "efs_name" {
  description = "EFS file system ID for storage class"
  type        = string
}

variable "rsa_key" {
  description = "Path to SSH private key file (optional if rsa_key_content is provided)"
  type        = string
  default     = ""
  sensitive = true
}

variable "rsa_key_content" {
  description = "SSH private key content (from Secrets Manager)"
  type        = string
  default     = null
  sensitive   = true
}

variable "db_password" {
  description = "PostgreSQL password for database connections"
  type        = string
  sensitive   = true
}

variable "solr_admin_password" {
  description = "Solr admin password for basic auth"
  type        = string
  sensitive   = true
}

variable "smtp_password" {
  type      = string
  sensitive = true
}

variable "aws_secret_key" {
  type = string
  sensitive = true
}

variable "ci_client_secret" {
  type = string
  sensitive = true
}

variable "ci_password" {
  type = string
  sensitive = true
}

variable "cluster_endpoint" {
  description = "EKS cluster endpoint"
  type        = string
  default     = ""
}

variable "cluster_ca_cert" {
  description = "EKS cluster certificate authority data"
  type        = string
  default     = ""
  sensitive   = true
}

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
  default     = ""
}

variable "aws_profile" {
  description = "AWS profile for EKS authentication"
  type        = string
  default     = "default"
}

variable "cert_manager_role_arn" {
  description = "IAM role ARN for cert-manager IRSA (Route53 DNS-01)"
  type        = string
  default     = ""
}
