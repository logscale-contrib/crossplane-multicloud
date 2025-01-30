resource "dns_address_validation" "authentik" {
  provider = dns-validation

  name = "${var.host}.${var.domain_name}"
  timeouts {
    create = "10m"
  }

}
