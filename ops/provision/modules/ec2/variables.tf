variable "namespace" {
  type = string
}

variable "vpc" {
  type = any
}

variable key_name {
  type = string
}

variable keypair {
  type = string
}

variable "sg_pub_id" {
  type = any
}

variable "fcrepo_instance" {
  default = "t2.xlarge"
}

variable "fcrepo_snapshot" {
  default = ""
}

variable "fcrepo_db_hostname" {
  type = string
}

variable "fcrepo_db_username" {
  type = string
}

variable "fcrepo_db_password" {
  type = string
}

variable "solr_collection" {
  type = string
}

variable "site24x7_key" {
  type = string
}

variable "site24x7_group" {
  type = string
}
