resource "dns_address_validation" "authentik" {
  provider = dns-validation

  name = "${var.host}.${var.domain_name}"
  timeouts {
    create = "10m"
  }

}

resource "checkmate_http_health" "authentik" {
  url                   = "https://${dns_address_validation.authentik.name}/-/health/live/"
  request_timeout       = 2000
  method                = "GET"
  interval              = 12
  status_code           = 200
  consecutive_successes = 10
  timeout               = 300000
}
