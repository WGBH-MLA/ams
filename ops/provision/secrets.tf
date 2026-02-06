# AWS Secrets Manager Integration
# Terraform reads secrets directly from AWS Secrets Manager

data "aws_secretsmanager_secret" "app_credentials" {
  name = "ams/ams2-app-credentials"
}

data "aws_secretsmanager_secret_version" "app_credentials" {
  secret_id = data.aws_secretsmanager_secret.app_credentials.id
}

locals {
  # Parse the JSON secret
  app_secrets = jsondecode(data.aws_secretsmanager_secret_version.app_credentials.secret_string)
  
  # Extract individual values
  s3_secret_key       = local.app_secrets.s3.SecretAccessKey
  smtp_password       = local.app_secrets.smtp.SecretAccessKey
  mysql_password      = local.app_secrets.mysql.password
  ci_client_secret    = local.app_secrets.sony_ci.client_secret
  ci_password         = local.app_secrets.sony_ci.password
  fcrepo_db_password  = local.app_secrets.fcrepo_db.password
  
  # SSH key from Secrets Manager (if exists)
  aapb_ssh_key        = try(local.app_secrets.aapb_ssh.private_key, null)
}
