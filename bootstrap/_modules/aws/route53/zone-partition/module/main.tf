module "zone" {
  source  = "terraform-aws-modules/route53/aws//modules/zones"
  version = "5.0.0"

  zones = {
    "${var.child_domain}.${var.parent_domain}" = {
      comment = "Zone for partition ${var.child_domain}.${var.parent_domain}"
    }
  }
  tags = {

    git_file             = "bootstrap/_modules/aws/route53/zone-partition/module/main.tf"
    git_last_modified_by = "ryan@dss-i.com"
    git_modifiers        = "ryan"
    git_org              = "logscale-contrib"
    git_repo             = "crossplane-multicloud"
    yor_name             = "zone"
    yor_trace            = "c44cb454-1af6-4ea9-8c9c-8f024ac26ca0"
  }
}

data "aws_route53_zone" "selected" {
  name = "${var.parent_domain}."
}

module "delegation_records" {
  source  = "terraform-aws-modules/route53/aws//modules/records"
  version = "5.0.0"

  zone_id = data.aws_route53_zone.selected.zone_id
  records = [{
    name    = var.child_domain
    type    = "NS"
    ttl     = 600
    records = module.zone.route53_zone_name_servers["${var.child_domain}.${var.parent_domain}"]
  }]
}
