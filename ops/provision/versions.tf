terraform {
  backend "pg" {}
  required_version = "> 0.13"

  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.9.0"
    }
  }
}

# Helm provider for root-level resources (eks_ingress.tf, eks_rancher.tf)
# Only connects when EKS cluster exists
provider "helm" {
  kubernetes = {
    host                   = var.create_eks_cluster ? aws_eks_cluster.main[0].endpoint : ""
    cluster_ca_certificate = var.create_eks_cluster ? base64decode(aws_eks_cluster.main[0].certificate_authority[0].data) : null
    exec = {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", var.cluster_name, "--region", var.region, "--profile", var.profile]
      command     = "aws"
    }
  }
}
