resource "tls_private_key" "pair" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P384"
}

resource "tls_self_signed_cert" "cert" {
  key_algorithm   = "ECDSA"
  private_key_pem = tls_private_key.pair.private_key_pem

  subject {
    common_name  = "${var.app_name} SAML Self Signed"
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

resource "authentik_certificate_key_pair" "saml" {
  name             = "${var.tenant}-${var.app_name} Self-signed SAML Certificate"
  certificate_data = tls_self_signed_cert.cert.cert_pem
  key_data         = tls_private_key.cert.private_key_pem
}
