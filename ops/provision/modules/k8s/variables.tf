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
}

variable "efs_name" {
  type = string
  default = "fs-0dd9f8ff037001c5d"
}

variable "rsa_key" {
  type = string
}

variable "mysql_password" {
  type = string
}

variable "smtp_password" {
  type = string
}

variable "aws_secret_key" {
  type = string
}

variable "ci_client_secret" {
  type = string
}

variable "ci_password" {
  type = string
}
