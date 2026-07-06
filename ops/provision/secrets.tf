# AWS Secrets Manager Integration
# Terraform reads secrets directly from AWS Secrets Manager

variable "aws_secret_name" {
  description = "AWS Secrets Manager secret name for app credentials (e.g., ams/ams2-app-credentials, ams/ams2-app-credentials-demo)"
  type        = string
}

data "aws_secretsmanager_secret" "app_credentials" {
  name = var.aws_secret_name
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
  ci_client_secret    = local.app_secrets.sony_ci.client_secret
  ci_password         = local.app_secrets.sony_ci.password

  # PostgreSQL password (shared across environments)
  db_password         = local.app_secrets.postgresql.password

  # Solr admin password
  solr_admin_password = local.app_secrets.solr.admin_password

  # SSH key from Secrets Manager (if exists)
  aapb_ssh_key        = try(local.app_secrets.aapb_ssh.private_key, null)
}