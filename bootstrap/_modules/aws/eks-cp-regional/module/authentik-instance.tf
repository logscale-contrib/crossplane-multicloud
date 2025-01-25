
# resource "kubectl_manifest" "authentik" {
#     count = var.region_name

#   yaml_body = templatefile("./manifests/helm-releases/authentik.yaml",
#     {
#     smtp_user     = var.smtp_user
#     smtp_password = var.smtp_password
#     smtp_server   = var.smtp_server
#     smtp_port     = var.smtp_port
#     smtp_tls      = "${var.smtp_tls}"
#     from_email    = var.from_email
#   })

# }
