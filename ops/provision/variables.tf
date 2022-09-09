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
