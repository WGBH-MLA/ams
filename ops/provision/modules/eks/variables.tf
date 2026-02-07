# ── Control Flags ──

variable "create_eks_cluster" {
  description = "Whether to create an EKS cluster"
  type        = bool
  default     = false
}

variable "deploy_k8s_apps" {
  description = "Whether to deploy k8s apps (Helm charts). Set to true AFTER EKS cluster is created."
  type        = bool
  default     = false
}

variable "create_efs" {
  description = "Whether to create a new EFS file system (true) or use existing (false)"
  type        = bool
  default     = true
}

# ── Cluster Config ──

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "k8s_version" {
  description = "Kubernetes version for EKS cluster"
  type        = string
  default     = "1.34"
}

variable "namespace" {
  description = "Project namespace for resource naming"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
}

variable "profile" {
  description = "AWS CLI profile"
  type        = string
}

# ── Node Config ──

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

# ── Networking (from networking module) ──

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "vpc_cidr_block" {
  description = "VPC CIDR block"
  type        = string
}

variable "private_subnets" {
  description = "List of private subnet IDs"
  type        = list(string)
}

variable "public_subnets" {
  description = "List of public subnet IDs"
  type        = list(string)
}

# ── EFS ──

variable "efs_name" {
  description = "Existing EFS file system ID (required if create_efs = false)"
  type        = string
  default     = ""
}

# ── Ingress ──

variable "nginx_ingress_chart_version" {
  description = "Version of the NGINX Inc Ingress Helm chart"
  type        = string
  default     = "2.4.3"
}

variable "ingress_nlb_eip" {
  description = "Optional Elastic IP allocation ID for Ingress NLB"
  type        = string
  default     = ""
}

# ── Rancher ──

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
