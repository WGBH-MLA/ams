module "networking" {
  source    = "./modules/networking"
  namespace = var.namespace
}

module "ssh" {
  source    = "./modules/ssh"
  namespace = var.namespace
}

module "ec2" {
  source             = "./modules/ec2"
  namespace          = var.namespace
  vpc                = module.networking.vpc
  sg_pub_id          = module.networking.sg_pub_id
  key_name           = module.ssh.key_name
  keypair            = module.ssh.ssh_keypair
  fcrepo_instance    = var.fcrepo_instance
  fcrepo_snapshot    = var.fcrepo_snapshot
  fcrepo_db_hostname = var.fcrepo_db_hostname
  fcrepo_db_username = var.fcrepo_db_username
  fcrepo_db_password = var.fcrepo_db_password
  solr_collection    = var.solr_collection
  site24x7_key       = var.site24x7_key
  site24x7_group     = var.site24x7_group
}

module "k8s" {
  source            = "./modules/k8s"
  efs_name          = var.efs_name
  region            = var.region
  namespace         = var.namespace
  rsa_key           = var.rsa_key
}
