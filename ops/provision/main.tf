# Data source for AWS account ID (used by KMS policy and other resources)
data "aws_caller_identity" "current" {}

module "networking" {
  source    = "./modules/networking"
  namespace = var.namespace
}

module "ec2" {
  source             = "./modules/ec2"
  namespace          = var.namespace
  vpc                = module.networking.vpc
  sg_pub_id          = module.networking.sg_pub_id
  key_name           = "${var.namespace}-key"
  keypair            = ""  # Existing instances already bootstrapped; user_data won't re-run
  fcrepo_instance    = var.fcrepo_instance
  fcrepo_snapshot    = var.fcrepo_snapshot
  fcrepo_db_hostname = var.fcrepo_db_hostname
  fcrepo_db_username = var.fcrepo_db_username
  fcrepo_db_password = local.fcrepo_db_password
  solr_collection    = var.solr_collection
}

# K8s apps module - only deploy AFTER EKS cluster is created and running
# Step 1: create_eks_cluster = true, deploy_k8s_apps = false → creates cluster
# Step 2: deploy_k8s_apps = true → deploys Helm charts & manifests
module "k8s" {
  source            = "./modules/k8s"
  deploy_k8s_apps   = var.deploy_k8s_apps
  efs_name          = var.create_efs ? aws_efs_file_system.main[0].id : var.efs_name
  region            = var.region
  namespace         = var.namespace
  
  # EKS cluster connection details
  cluster_endpoint  = var.create_eks_cluster ? aws_eks_cluster.main[0].endpoint : ""
  cluster_ca_cert   = var.create_eks_cluster ? aws_eks_cluster.main[0].certificate_authority[0].data : ""
  cluster_name      = var.cluster_name
  aws_profile       = var.profile
  
  # SSH key: use var if provided, otherwise pass content from Secrets Manager
  rsa_key           = var.rsa_key
  rsa_key_content   = local.aapb_ssh_key
  
  # cert-manager IRSA for Route53 DNS-01 challenges
  cert_manager_role_arn = var.create_eks_cluster ? aws_iam_role.cert_manager[0].arn : ""

  # Secrets automatically loaded from AWS Secrets Manager (see secrets.tf)
  mysql_password    = local.mysql_password
  smtp_password     = local.smtp_password
  aws_secret_key    = local.s3_secret_key
  ci_client_secret  = local.ci_client_secret
  ci_password       = local.ci_password

  # Note: AWS LB Controller (eks_ingress.tf) must be deployed and healthy before
  # this module's Helm releases run — its webhook intercepts Service creation.
  # On first deploy, run with deploy_k8s_apps=false first, then flip to true.
}
