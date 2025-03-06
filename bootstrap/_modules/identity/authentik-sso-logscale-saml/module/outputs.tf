
output "sso" {
  value = {
    type                = "saml"
    url                 = resource.authentik_provider_saml.this.url_sso_redirect
    issuer              = resource.authentik_provider_saml.this.issuer
    signing_certificate = tls_self_signed_cert.cert.cert_pem
    metadata            = data.authentik_provider_saml_metadata.provider.metadata
  }
}
