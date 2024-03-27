#!/bin/bash

export HELM_EXPERIMENTAL_OCI=1
export HELM_RELEASE_NAME=ams-$1
export KUBE_NAMESPACE=ams-$1
export HELM_EXTRA_ARGS="--values ops/$1-deploy.yaml"
export KUBECONFIG="${KUBECONFIG:-./ops/provision/kube_config.yaml}"
export SOLR_PASSWORD="-"
export TAG=$2
export DEPLOY_TAG=$2
export REPO_LOWER=wgbh-mla/ams

export DEPLOY_IMAGE=ghcr.io/${REPO_LOWER}
export WORKER_IMAGE=ghcr.io/${REPO_LOWER}/worker
DOLLAR=$ envsubst < ops/$1-deploy.tmpl.yaml > ops/$1-deploy.yaml
./bin/helm_deploy ams-$1 ams-$1
