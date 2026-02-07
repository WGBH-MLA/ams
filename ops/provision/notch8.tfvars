# AMS EKS Cluster — Notch8 workspace configuration
# This file is safe to commit (no secrets — all secrets come from AWS Secrets Manager)

profile   = "gbh"
region    = "us-east-1"
namespace = "AMS"

# EC2 (fcrepo instances)
fcrepo_instance    = "t2.xlarge"
fcrepo_snapshot    = ""
fcrepo_db_hostname = "localhost"
fcrepo_db_username = "admin"
solr_collection    = "hyrax-development"

# EKS Cluster
create_eks_cluster = true
deploy_k8s_apps    = true
cluster_name       = "AMS"
k8s_version        = "1.34"
node_instance_type = "t3.large"
desired_size       = 3
min_size           = 2
max_size           = 6
create_efs         = false
efs_name           = "fs-0dd9f8ff037001c5d"

# Rancher
enable_rancher        = true
rancher_chart_version = "2.13.2"
rancher_hostname      = "ams2-rancher.wgbh-mla.org"
