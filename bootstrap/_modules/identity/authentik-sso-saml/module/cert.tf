resource "tls_private_key" "kp" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P384"
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

resource "authentik_certificate_key_pair" "saml" {
  name             = "${var.tenantName}-${var.appName} Self-signed SAML Certificate"
  certificate_data = tls_self_signed_cert.cert.cert_pem
  key_data         = tls_private_key.kp.private_key_pem
}
