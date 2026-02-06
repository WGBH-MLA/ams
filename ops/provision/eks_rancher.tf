# Rancher - Kubernetes Management Platform
# Deployed to the AMS EKS cluster for cluster visibility and management
#
# TLS: cert-manager annotation on the ingress triggers automatic
#       Let's Encrypt certificate provisioning via the existing
#       letsencrypt-prod ClusterIssuer.

resource "helm_release" "rancher" {
  count            = var.create_eks_cluster && var.deploy_k8s_apps && var.enable_rancher ? 1 : 0
  name             = "rancher"
  repository       = "https://releases.rancher.com/server-charts/latest"
  chart            = "rancher"
  version          = var.rancher_chart_version
  namespace        = "cattle-system"
  create_namespace = true
  wait             = true
  timeout          = 900

  set = [
    # Core
    {
      name  = "hostname"
      value = var.rancher_hostname
    },
    {
      name  = "replicas"
      value = "2"
    },
    # TLS — cert-manager creates the secret automatically via ingress annotation
    {
      name  = "ingress.tls.source"
      value = "secret"
    },
    {
      name  = "ingress.ingressClassName"
      value = "nginx"
    },
    {
      name  = "ingress.extraAnnotations.cert-manager\\.io/cluster-issuer"
      value = "letsencrypt-prod-dns"
    },
    # Audit logging
    {
      name  = "auditLog.enabled"
      value = "true"
    },
    {
      name  = "auditLog.level"
      value = "1"
    },
    # Bootstrap — change this on first login
    {
      name  = "bootstrapPassword"
      value = "admin"
    },
    # Resource limits
    {
      name  = "resources.requests.cpu"
      value = "500m"
    },
    {
      name  = "resources.requests.memory"
      value = "512Mi"
    },
    {
      name  = "resources.limits.cpu"
      value = "1000m"
    },
    {
      name  = "resources.limits.memory"
      value = "1Gi"
    },
  ]

  depends_on = [
    helm_release.nginx_ingress,
    helm_release.aws_load_balancer_controller,
  ]
}
