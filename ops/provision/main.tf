module "networking" {
  source    = "./modules/networking"
  namespace = var.namespace
}

module "eks" {
  source             = "./modules/eks"
  create_eks_cluster = var.create_eks_cluster
  deploy_k8s_apps    = var.deploy_k8s_apps
  create_efs         = var.create_efs
  efs_name           = var.efs_name

  # Cluster config
  cluster_name = var.cluster_name
  k8s_version  = var.k8s_version
  namespace    = var.namespace
  region       = var.region
  profile      = var.profile

  # Node config
  node_instance_type = var.node_instance_type
  desired_size       = var.desired_size
  min_size           = var.min_size
  max_size           = var.max_size

  # Networking
  vpc_id          = module.networking.vpc.vpc_id
  vpc_cidr_block  = module.networking.vpc.vpc_cidr_block
  private_subnets = module.networking.vpc.private_subnets
  public_subnets  = module.networking.vpc.public_subnets

  # Ingress
  nginx_ingress_chart_version = var.nginx_ingress_chart_version
  ingress_nlb_eip             = var.ingress_nlb_eip

  # Rancher
  enable_rancher        = var.enable_rancher
  rancher_chart_version = var.rancher_chart_version
  rancher_hostname      = var.rancher_hostname
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
  efs_name          = module.eks.efs_id
  region            = var.region
  namespace         = var.namespace
  
  # EKS cluster connection details
  cluster_endpoint  = module.eks.cluster_endpoint
  cluster_ca_cert   = module.eks.cluster_ca_data
  cluster_name      = var.cluster_name
  aws_profile       = var.profile
  
  # SSH key: use var if provided, otherwise pass content from Secrets Manager
  rsa_key           = var.rsa_key
  rsa_key_content   = local.aapb_ssh_key
  
  # cert-manager IRSA for Route53 DNS-01 challenges
  cert_manager_role_arn = module.eks.cert_manager_role_arn

  # Secrets automatically loaded from AWS Secrets Manager (see secrets.tf)
  db_password         = local.db_password
  solr_admin_password = local.solr_admin_password
  smtp_password       = local.smtp_password
  aws_secret_key      = local.s3_secret_key
  ci_client_secret    = local.ci_client_secret
  ci_password         = local.ci_password

  # Note: AWS LB Controller (modules/eks/ingress.tf) must be deployed and healthy
  # before this module's Helm releases run — its webhook intercepts Service creation.
  # On first deploy, run with deploy_k8s_apps=false first, then flip to true.
}
