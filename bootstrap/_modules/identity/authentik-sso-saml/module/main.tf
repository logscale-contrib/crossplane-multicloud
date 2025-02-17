# Create an application with a provider attached and policies applied
locals {
  fqdn      = "${var.appName}.${var.tenantName}.${var.domain_name}"
  namespace = "${var.tenantName}-${var.appName}"
}


data "aws_secretsmanager_secret" "secret-token" {
  name = var.authentik_token_ssm_name
}
data "aws_secretsmanager_secret_version" "secret-token" {
  secret_id = data.aws_secretsmanager_secret.secret-token.id
}

data "authentik_flow" "default-authorization-flow" {
  slug = "default-provider-authorization-implicit-consent"
}

data "authentik_property_mapping_provider_saml" "this" {
  managed_list = [
    "goauthentik.io/providers/saml/email",
    "goauthentik.io/providers/saml/groups",
    "goauthentik.io/providers/saml/name",
    "goauthentik.io/providers/saml/uid",
    "goauthentik.io/providers/saml/upn",
    "goauthentik.io/providers/saml/username"
  ]
}

data "authentik_property_mapping_provider_saml" "username" {
  managed = "goauthentik.io/providers/saml/username"
}

data "authentik_flow" "default-provider-invalidation-flow" {
  slug = "default-provider-invalidation-flow"
}

# data "authentik_certificate_key_pair" "generated" {
#   name              = authentik_certificate_key_pair.saml.name
#   fetch_certificate = true
#   fetch_key         = false
# }

resource "authentik_provider_saml" "this" {
  name = "${local.namespace}-saml"

  # issuer = "sso.${var.domain_name}"

  authorization_flow = data.authentik_flow.default-authorization-flow.id
  acs_url            = "https://${local.fqdn}/api/v1/saml/acs"
  sp_binding         = "post"
  signing_kp         = authentik_certificate_key_pair.saml.id
  # signing_kp = data.authentik_certificate_key_pair.generated.id

  audience          = "https://${local.fqdn}/api/v1/saml/metadata"
  property_mappings = data.authentik_property_mapping_provider_saml.this.ids
  name_id_mapping   = data.authentik_property_mapping_provider_saml.username.id
  invalidation_flow = data.authentik_flow.default-provider-invalidation-flow.id
}

data "authentik_provider_saml_metadata" "provider" {
  provider_id = authentik_provider_saml.this.id
}

resource "random_uuid" "slug" {
}

resource "authentik_application" "name" {
  name              = "${var.tenantName}-${var.appName}"
  slug              = resource.random_uuid.slug.result
  group             = var.tenantName
  protocol_provider = authentik_provider_saml.this.id
  # backchannel_providers = [
  #   authentik_provider_scim.logscale.id
  # ]
}
