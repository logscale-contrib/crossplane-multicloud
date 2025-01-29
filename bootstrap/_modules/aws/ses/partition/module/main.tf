resource "aws_sesv2_configuration_set" "main" {
  configuration_set_name = var.partition

  delivery_options {
    tls_policy = "REQUIRE"
  }

  reputation_options {
    reputation_metrics_enabled = false
  }

  sending_options {
    sending_enabled = true
  }

  suppression_options {
    suppressed_reasons = ["BOUNCE", "COMPLAINT"]
  }

  tags = {

    git_file             = "bootstrap/_modules/aws/ses/partition/module/main.tf"
    git_last_modified_by = "ryan@dss-i.com"
    git_modifiers        = "ryan"
    git_org              = "logscale-contrib"
    git_repo             = "crossplane-multicloud"
    yor_name             = "main"
    yor_trace            = "e9925086-4dbb-48ec-8e94-f8b509d9a8e3"
  }
}

resource "aws_sesv2_email_identity" "main" {
  email_identity         = var.domain
  configuration_set_name = aws_sesv2_configuration_set.main.configuration_set_name

  tags = {

    git_file             = "bootstrap/_modules/aws/ses/partition/module/main.tf"
    git_last_modified_by = "ryan@dss-i.com"
    git_modifiers        = "ryan"
    git_org              = "logscale-contrib"
    git_repo             = "crossplane-multicloud"
    yor_name             = "main"
    yor_trace            = "e0715f2b-f5e9-4f39-806e-1cca6ab1c8a2"
  }
}

resource "aws_route53_record" "dkim" {
  count = 3

  zone_id = var.domain_zone_id
  name    = "${aws_sesv2_email_identity.main.dkim_signing_attributes[0].tokens[count.index]}._domainkey"
  type    = "CNAME"
  ttl     = "600"
  records = ["${aws_sesv2_email_identity.main.dkim_signing_attributes[0].tokens[count.index]}.dkim.amazonses.com"]

  depends_on = [aws_sesv2_email_identity.main]
}
