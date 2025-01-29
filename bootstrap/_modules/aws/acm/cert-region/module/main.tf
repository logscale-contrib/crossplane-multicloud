module "acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "5.1.1"

  domain_name = "*.${var.cert_domain}"
  zone_id     = var.parent_zone_id

  validation_method = "DNS"

  subject_alternative_names = [
    "*.${var.cert_domain}",
    "${var.cert_domain}",
  ]

  wait_for_validation = true

  key_algorithm = "EC_secp384r1"

  tags = {

    git_file             = "bootstrap/_modules/aws/acm/cert-region/module/main.tf"
    git_last_modified_by = "ryan@dss-i.com"
    git_modifiers        = "ryan"
    git_org              = "logscale-contrib"
    git_repo             = "crossplane-multicloud"
    yor_name             = "acm"
    yor_trace            = "884485de-bce1-4d6b-926c-7de8cbb56902"
  }
}
