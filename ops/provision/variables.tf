variable "profile" {
  default = "ams"
}

variable "namespace" {
  description = "The project namespace to use for unique resource naming"
  default     = "TEST"
  type        = string
}

variable "region" {
  description = "AWS region"
  default     = "us-east-2"
  type        = string
}

# FCRepo EC2 Variables
variable "fcrepo_instance" {
  type    = string
  default = "t2.xlarge"
}

variable "fcrepo_snapshot" {
  type    = string
  default = ""
}

variable "fcrepo_db_hostname" {
  type    = string
  default = ""
}

variable "fcrepo_db_username" {
  type    = string
  default = ""
}

variable "solr_collection" {
  type    = string
  default = ""
}

variable "create_efs" {
  description = "Whether to create a new EFS file system (true) or use existing (false)"
  type        = bool
  default     = true
}

variable "efs_name" {
  description = "Existing EFS file system ID (required if create_efs = false)"
  type        = string
  default     = ""
}

variable "rsa_key" {
  description = "Path to AAPB SSH private key - can be provided or will be read from AWS Secrets Manager"
  type        = string
  default     = ""
}

variable "mysql_password" {
  description = "MySQL password - can be provided or will be read from AWS Secrets Manager"
  type        = string
  sensitive   = true
  default     = ""
}

variable "smtp_password" {
  description = "SMTP password - can be provided or will be read from AWS Secrets Manager"
  type        = string
  sensitive   = true
  default     = ""
}

variable "aws_secret_key" {
  description = "AWS S3 secret key - can be provided or will be read from AWS Secrets Manager"
  type        = string
  sensitive   = true
  default     = ""
}

variable "ci_client_secret" {
  description = "Sony CI client secret - can be provided or will be read from AWS Secrets Manager"
  type        = string
  sensitive   = true
  default     = ""
}

variable "ci_password" {
  description = "Sony CI password - can be provided or will be read from AWS Secrets Manager"
  type        = string
  sensitive   = true
  default     = ""
}

# EKS Cluster Variables
variable "create_eks_cluster" {
  description = "Whether to create an EKS cluster"
  type        = bool
  default     = false
}

variable "deploy_k8s_apps" {
  description = "Whether to deploy k8s apps (Helm charts, manifests). Set to true AFTER EKS cluster is created."
  type        = bool
  default     = false
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "r2-gbh-ams2"
}

variable "k8s_version" {
  description = "Kubernetes version for EKS cluster"
  type        = string
  default     = "1.34"
}

variable "node_instance_type" {
  description = "EC2 instance type for EKS nodes"
  type        = string
  default     = "t3.xlarge"
}

variable "desired_size" {
  description = "Desired number of EKS nodes"
  type        = number
  default     = 3
}

variable "min_size" {
  description = "Minimum number of EKS nodes"
  type        = number
  default     = 3
}

variable "max_size" {
  description = "Maximum number of EKS nodes"
  type        = number
  default     = 6
}

# Ingress / Load Balancer Variables
variable "nginx_ingress_chart_version" {
  description = "Version of the NGINX Inc Ingress Helm chart"
  type        = string
  default     = "2.4.3"
}

variable "ingress_nlb_eip" {
  description = "Optional Elastic IP allocation ID for Ingress NLB (leave empty for dynamic IP)"
  type        = string
  default     = ""
}

# Rancher Variables
variable "enable_rancher" {
  description = "Deploy Rancher to the EKS cluster"
  type        = bool
  default     = false
}

variable "rancher_chart_version" {
  description = "Rancher Helm chart version"
  type        = string
  default     = "2.13.2"
}

variable "rancher_hostname" {
  description = "Hostname for the Rancher UI"
  type        = string
  default     = "ams2-rancher.wgbh-mla.org"
}
