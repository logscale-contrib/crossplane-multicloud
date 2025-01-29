module "acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "5.1.1"

  domain_name = "*.${var.tenant}.${var.cert_domain}"
  zone_id     = var.parent_zone_id

  validation_method = "DNS"

  subject_alternative_names = [
    "*.${var.tenant}.${var.cert_domain}",
    "${var.tenant}.${var.cert_domain}",
  ]

  wait_for_validation = true

  key_algorithm = "EC_secp384r1"

  tags = {

    git_file             = "bootstrap/_modules/aws/acm/cert-tenant/module/main.tf"
    git_last_modified_by = "ryan@dss-i.com"
    git_modifiers        = "ryan"
    git_org              = "logscale-contrib"
    git_repo             = "crossplane-multicloud"
    yor_name             = "acm"
    yor_trace            = "cbd65683-0fb2-4bf1-a701-451c1a235b96"
  }
}
