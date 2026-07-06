# External Secrets Integration with AMS

We use AWS Secrets Manager for storiing and managing secrets required by
applications that run in our EKS clusters.

This requires a few external services to be installed and properly configured.

## ExternalSecrets Helm chart



aws iam create-role \
  --role-name ams-external-secrets-role \
  --assume-role-policy-document file://config/external_secrets/external-secrets-trust.json

