# data "authentik_flow" "flow_device_code" {
#   slug = "default-invalidation-flow"
# }

data "authentik_flow" "flow_invalidation" {
  slug = "default-invalidation-flow"
}

data "authentik_flow" "flow_recovery" {
  depends_on = [authentik_flow.recovery]
  slug       = "account-recovery"
}

data "authentik_flow" "flow_user_settings" {
  slug = "default-user-settings-flow"
}


resource "authentik_brand" "lr" {
  domain = "${var.host}.${var.domain_name}"

  default = false

  branding_favicon = "/static/dist/assets/icons/icon.png"
  branding_logo    = "/static/dist/assets/icons/icon_left_brand.svg"
  branding_title   = "LogsRLife"

  flow_authentication = authentik_flow.lr.uuid
  flow_invalidation   = data.authentik_flow.flow_invalidation.id
  flow_recovery       = data.authentik_flow.flow_recovery.id
  flow_user_settings  = data.authentik_flow.flow_user_settings.id

}
