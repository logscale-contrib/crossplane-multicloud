
resource "kubectl_manifest" "authentik" {
  count = (
    var.authentik_state[var.region_name]["name"] == "normal"
  ) ? 1 : 0

  yaml_body = templatefile("./manifests/helm-releases/authentik.yaml",
    {
      namespace     = var.authentik_namespace
      smtp_user     = module.iam_ses_user.iam_access_key_id
      smtp_password = module.iam_ses_user.iam_access_key_ses_smtp_password_v4
      smtp_server   = var.smtp_server
      smtp_port     = var.smtp_port
      smtp_tls      = "${var.smtp_tls}"
      from_email    = var.from_email
  })

}
