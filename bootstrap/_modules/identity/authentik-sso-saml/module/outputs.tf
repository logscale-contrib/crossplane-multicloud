output "metadata" {
  value = data.authentik_provider_saml_metadata.provider.metadata
}

output "url" {
  value = resource.authentik_provider_saml.this.url_sso_redirect
}

output "signing_certificate" {
  value = tls_self_signed_cert.cert.cert_pem
}

output "issuer" {
  value = resource.authentik_provider_saml.this.issuer
}

# output "scim_token" {
#   value     = random_password.scim.result
#   sensitive = true
# }
