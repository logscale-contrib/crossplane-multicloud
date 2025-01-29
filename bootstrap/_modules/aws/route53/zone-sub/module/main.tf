module "zone" {
  source  = "terraform-aws-modules/route53/aws//modules/zones"
  version = "4.1.0"

  zones = {
    "${var.child_domain}.${var.parent_domain}" = {
      comment = "Zone for partition ${var.child_domain}.${var.parent_domain}"
    }
  }
  tags = {

    git_file             = "bootstrap/_modules/aws/route53/zone-sub/module/main.tf"
    git_last_modified_by = "ryan@dss-i.com"
    git_modifiers        = "ryan"
    git_org              = "logscale-contrib"
    git_repo             = "crossplane-multicloud"
    yor_name             = "zone"
    yor_trace            = "58a5323a-d20d-4491-92b9-c3c16c4a87c7"
  }
}


module "delegation_records" {
  source  = "terraform-aws-modules/route53/aws//modules/records"
  version = "4.1.0"

  zone_id = var.parent_zone_id
  records = [{
    name    = var.child_domain
    type    = "NS"
    ttl     = 600
    records = module.zone.route53_zone_name_servers["${var.child_domain}.${var.parent_domain}"]
  }]
}
