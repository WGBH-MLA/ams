#!/bin/bash

# Install external-secrets dependency Helm chart does the following:
# * Creates the `external-secrets` namespace
# * Installs the ExternalSecrets Operator in that namespace
# * Installs the ExternalSecret CRDs in the cluster (ClusterSecretStore, etc.)
helm repo add external-secrets https://charts.external-secrets.io
helm repo update
helm upgrade --install external-secrets external-secrets/external-secrets \
  --namespace external-secrets \
  --create-namespace \
  --set installCRDs=true

# Wait for the CRDs to be established before proceeding with the deployment of the main application.
# TODO: Do we need to handle a failure case here, or will it error out on it's own?
kubectl wait --for=condition=Established \
  crd/clustersecretstores.external-secrets.io \
  --timeout=60s

# Set up the environment variables for the Helm deployment and run the custom script.
export HELM_EXPERIMENTAL_OCI=1
export HELM_RELEASE_NAME=ams-$1
export KUBE_NAMESPACE=ams-$1
export HELM_EXTRA_ARGS="--values ops/$1-deploy.yaml"
export SOLR_PASSWORD="-"
export TAG=$2
export DEPLOY_TAG=$2
export REPO_LOWER=wgbh-mla/ams

export DEPLOY_IMAGE=ghcr.io/${REPO_LOWER}
export WORKER_IMAGE=ghcr.io/${REPO_LOWER}/worker

# Create the actual deployment YAML file from the template, using envsubst to
# replace template variables with environment variable values.
envsubst < ops/$1-deploy.tmpl.yaml > ops/$1-deploy.yaml

# Run custom helm_deploy script for the user-specified deployment environment.
# NOTE: the value of $1 is supposed to come from the user-selected option specified
# in the Github Actions `deploy` workflow (see `.github/workflows/deploy.yaml`).
./bin/helm_deploy ams-$1 ams-$1
