terraform {
  required_providers {
    rancher2 = {
      source = "rancher/rancher2"
      version = "1.11.0"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.7.0"
    }
  }
}


provider "helm" {
  kubernetes {
    config_path = var.kubeconfig
  }
}

provider "kubectl" {
  config_path = var.kubeconfig
}

provider "kubernetes" {
  config_path = var.kubeconfig
}

resource "helm_release" "ingress-nginx" {
  name = "ingress-nginx"
  namespace = "ingress-nginx"
  create_namespace = true
  version = "4.3.0"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart = "ingress-nginx"
  values = [
    file("modules/k8s/files/ingress-nginx-values.yaml")
  ]
}

resource "helm_release" "eks_efs_csi_driver" {
  chart      = "aws-efs-csi-driver"
  name       = "efs"
  namespace  = "storage"
  create_namespace = true
  repository = "https://kubernetes-sigs.github.io/aws-efs-csi-driver/"

  set {
    name  = "image.repository"
    value = "602401143452.dkr.ecr.${var.region}.amazonaws.com/eks/aws-efs-csi-driver"
  }
}

resource "kubernetes_storage_class" "storage_class" {
  storage_provisioner = "efs.csi.aws.com"

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
  name = "cert-manager"
  namespace = "cert-manager"
  create_namespace = true
  version = "1.1.0"
  repository = "https://charts.jetstack.io"
  chart = "cert-manager"

  set {
    name  = "installCRDs"
    value = "true"
  }
}

resource "kubectl_manifest" "prod_issuer" {
  depends_on = [helm_release.cert_manager]
  yaml_body = file("modules/k8s/files/prod_issuer.yaml")
}

resource "kubectl_manifest" "staging_issuer" {
  depends_on = [helm_release.cert_manager]
  yaml_body = file("modules/k8s/files/staging_issuer.yaml")
}
