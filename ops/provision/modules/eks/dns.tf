# Route 53 DNS Records for AMS
# Points ams2*.wgbh-mla.org CNAMEs to the NGINX Ingress NLB

# Look up the NLB created by the NGINX Ingress controller
# The NLB is named "${cluster_name}-ingress" via the Helm values template
data "aws_lb" "ingress" {
  count = var.create_eks_cluster && var.deploy_k8s_apps ? 1 : 0
  name  = "${lower(var.cluster_name)}-ingress"

  depends_on = [helm_release.nginx_ingress]
}

locals {
  # All AMS subdomains that need to point to the ingress NLB
  ams_subdomains = merge(
    {
      "ams2"      = "ams2.wgbh-mla.org"      # production
      "ams2-demo" = "ams2-demo.wgbh-mla.org"  # demo
    },
    var.enable_rancher ? { "ams2-rancher" = var.rancher_hostname } : {}
  )
}

resource "aws_route53_record" "ams" {
  for_each = var.create_eks_cluster && var.deploy_k8s_apps ? local.ams_subdomains : {}

  zone_id = "Z1NW9A2RAA74H1"  # wgbh-mla.org hosted zone
  name    = each.value
  type    = "CNAME"
  ttl     = 300
  records = [data.aws_lb.ingress[0].dns_name]
}
