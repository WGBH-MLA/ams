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

variable "fcrepo_instance" {
  type        = string
  default = "t2.xlarge"
}

variable "fcrepo_snapshot" {
  type        = string
}

variable "fcrepo_db_hostname" {
  type        = string
}

variable "fcrepo_db_username" {
  type        = string
}

variable "fcrepo_db_password" {
  type        = string
}

variable "solr_collection" {
  type        = string
}

variable "site24x7_key" {
  type = string
}

variable "site24x7_group" {
  type = string
}

variable "kubeconfig" {
  type = string
  default = "./kube_config.yaml"
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
