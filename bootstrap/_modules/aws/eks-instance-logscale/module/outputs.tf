output "logscale_bucket_prefix_base" {
  value = local.bucket_prefix
}
output "logscale_account_arn" {
  value = module.logscale_service_account.iam_role_arn
}
output "logscale_account" {
  value = var.logscale_namespace
}
output "logscale_account_annotations" {
  value = {
    "eks.amazonaws.com/role-arn" = module.logscale_service_account.iam_role_arn
  }
}

data "aws_region" "current" {}
output "logscale_buckets" {
  value = {
    type   = "aws"
    region = data.aws_region.current.name
    id     = var.data_bucket_id
    prefixes = {
      storage = "${local.bucket_prefix}/storage/"
      export  = "${local.bucket_prefix}/export/"
      archive = "${local.bucket_prefix}/archive/"
    }
  }
}
locals {
  ingress_group = var.logscale_namespace == "partition-logscale" ? "partition" : "region"
}
output "logscale_ingress_common" {
  value = {
    annotations = {
      "alb.ingress.kubernetes.io/listen-ports" = "[{\"HTTP\": 80}, {\"HTTPS\":443}]"
      "alb.ingress.kubernetes.io/ssl-redirect" = "443"
    }
    ingressClassName = "alb-${local.ingress_group}"
    tls              = true
  }
}
