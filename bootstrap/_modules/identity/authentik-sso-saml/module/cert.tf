resource "tls_private_key" "kp" {
  #   algorithm   = "ECDSA"
  #   ecdsa_curve = "P384"
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "tls_self_signed_cert" "cert" {

  private_key_pem = tls_private_key.kp.private_key_pem

  subject {
    common_name  = "${var.appName} SAML Self Signed"
    organization = var.domain_name
  }

  validity_period_hours = 24 * 365
  early_renewal_hours   = 24 * 90
  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    # "server_auth",
  ]
}
resource "random_string" "crt-name" {
  length           = 4
  special          = false
  numeric          = false
  upper            = false
  override_special = "/@£$"
  keepers          = { cert = tls_self_signed_cert.cert.cert_pem }
}

resource "authentik_certificate_key_pair" "saml" {
  name             = "${var.tenantName}-${var.appName} Self-signed SAML Certificate ${random_string.crt-name.result}"
  certificate_data = tls_self_signed_cert.cert.cert_pem
  key_data         = tls_private_key.kp.private_key_pem
}
