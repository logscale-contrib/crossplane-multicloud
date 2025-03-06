
output "logscale_sso" {
  value = {
    method = "saml"
    saml = {
      groupMembershipAttribute = "http://schemas.xmlsoap.org/claims/Group"
      signOnUrl                = resource.authentik_provider_saml.this.url_sso_redirect
      entityID                 = resource.authentik_provider_saml.this.issuer
      idpCertificate           = tls_self_signed_cert.cert.cert_pem
      metadata                 = data.authentik_provider_saml_metadata.provider.metadata
    }
  }
}
