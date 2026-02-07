terraform {
  required_providers {
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.7.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.9.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.20.0"
    }
  }
}


provider "helm" {
  kubernetes = {
    host                   = var.cluster_endpoint
    cluster_ca_certificate = var.cluster_ca_cert != "" ? base64decode(var.cluster_ca_cert) : null
    exec = {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", var.cluster_name, "--region", var.region, "--profile", var.aws_profile]
      command     = "aws"
    }
  }
}

provider "kubectl" {
  host                   = var.cluster_endpoint
  cluster_ca_certificate = var.cluster_ca_cert != "" ? base64decode(var.cluster_ca_cert) : null
  load_config_file       = false

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "get-token", "--cluster-name", var.cluster_name, "--region", var.region, "--profile", var.aws_profile]
    command     = "aws"
  }
}

provider "kubernetes" {
  host                   = var.cluster_endpoint
  cluster_ca_certificate = var.cluster_ca_cert != "" ? base64decode(var.cluster_ca_cert) : null

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "get-token", "--cluster-name", var.cluster_name, "--region", var.region, "--profile", var.aws_profile]
    command     = "aws"
  }
}

# Note: Ingress controller (NGINX Inc) is deployed via eks_ingress.tf at root level
# using AWS Load Balancer Controller + nginx-ingress Helm chart
#
# Note: EFS CSI driver is installed as an EKS managed addon (eks_addons.tf),
# NOT as a Helm release, to avoid ClusterRole ownership conflicts.

resource "kubernetes_storage_class_v1" "storage_class" {
  count               = var.deploy_k8s_apps ? 1 : 0
  storage_provisioner = "efs.csi.aws.com"
  reclaim_policy      = "Retain"

  parameters = {
    directoryPerms   = "700"
    fileSystemId     = trimspace(var.efs_name)
    provisioningMode = "efs-ap"
  }

  metadata {
    name = "efs-sc"
  }
}

resource "helm_release" "cert_manager" {
  count            = var.deploy_k8s_apps ? 1 : 0
  name             = "cert-manager"
  namespace        = "cert-manager"
  create_namespace = true
  version          = "v1.19.3"
  repository       = "https://charts.jetstack.io"
  chart            = "cert-manager"

  set = [
    {
      name  = "installCRDs"
      value = "true"
    },
    {
      name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
      value = var.cert_manager_role_arn
    },
  ]
}

resource "kubectl_manifest" "prod_issuer" {
  count      = var.deploy_k8s_apps ? 1 : 0
  depends_on = [helm_release.cert_manager]
  yaml_body  = file("modules/k8s/files/prod_issuer.yaml")
}

resource "kubectl_manifest" "staging_issuer" {
  count      = var.deploy_k8s_apps ? 1 : 0
  depends_on = [helm_release.cert_manager]
  yaml_body  = file("modules/k8s/files/staging_issuer.yaml")
}

resource "kubectl_manifest" "prod_dns_issuer" {
  count      = var.deploy_k8s_apps ? 1 : 0
  depends_on = [helm_release.cert_manager]
  yaml_body  = file("modules/k8s/files/prod_dns_issuer.yaml")
}

resource "helm_release" "secrets_replicator" {
  count            = var.deploy_k8s_apps ? 1 : 0
  chart            = "kubernetes-replicator"
  name             = "kubernetes-replicator"
  namespace        = "default"
  version          = "2.12.2"
  create_namespace = true
  repository       = "https://helm.mittwald.de"
}

resource "kubectl_manifest" "aapb_ssh_keys" {
  count     = var.deploy_k8s_apps ? 1 : 0
  yaml_body = templatefile("modules/k8s/files/aapb_ssh_keys.yaml", {
    rsa_key = var.rsa_key != "" ? filebase64(var.rsa_key) : base64encode(var.rsa_key_content)
  })
}

resource "kubectl_manifest" "app_secrets" {
  count     = var.deploy_k8s_apps ? 1 : 0
  yaml_body = templatefile("modules/k8s/files/app_secrets.yaml", {
    db_password      = base64encode(var.db_password),
    solr_admin_password = base64encode(var.solr_admin_password),
    smtp_password    = base64encode(var.smtp_password),
    aws_secret_key   = base64encode(var.aws_secret_key),
    ci_client_secret = base64encode(var.ci_client_secret),
    ci_password      = base64encode(var.ci_password)
  })
}
