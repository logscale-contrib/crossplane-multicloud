resource "dns_address_validation" "authentik" {

  name = "${var.host}.${var.domain_name}"
  timeouts {
    create = "10m"
  }

}
