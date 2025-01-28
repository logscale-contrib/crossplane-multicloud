module "authentik_server" {

  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.52.2"

  role_name_prefix = "${var.authentik_namespace}-server"
  role_path        = var.iam_role_path

  role_policy_arns = {
    "authentik_cookie_key_policy_arn" = var.authentik_cookie_key_policy_arn
  }

  oidc_providers = {
    main = {
      provider_arn               = var.oidc_provider_arn
      namespace_service_accounts = ["${var.authentik_namespace}:authentik-server"]
    }
  }
}

module "authentik_worker" {

  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.52.2"

  role_name_prefix = "${var.authentik_namespace}-woker"
  role_path        = var.iam_role_path

  role_policy_arns = {
    "authentik_cookie_key_policy_arn" = var.authentik_cookie_key_policy_arn
  }

  oidc_providers = {
    main = {
      provider_arn               = var.oidc_provider_arn
      namespace_service_accounts = ["${var.authentik_namespace}:authentik-worker"]
    }
  }
}

# resource "kubernetes_service_account" "authentik_server" {
#   metadata {
#     name = "authentik-server"
#     annotations = {
#       "iam.amazonaws.com/role" = module.authentik_server.iam_role_arn
#     }
#   }
# }

# resource "kubernetes_service_account" "authentik_worker" {
#   metadata {
#     name = "authentik-worker"
#     annotations = {
#       "iam.amazonaws.com/role" = module.authentik_worker.iam_role_arn
#     }
#   }
# }


resource "kubectl_manifest" "authentik_instance" {
  count = (
    var.authentik_state[var.region_name]["mode"] == "normal"
  ) ? 1 : 0

  yaml_body = templatefile("./manifests/helm-releases/authentik.yaml",
    {
      region_name                      = var.region_name
      namespace                        = var.authentik_namespace
      smtp_user                        = module.iam_ses_user.iam_access_key_id
      smtp_password                    = module.iam_ses_user.iam_access_key_ses_smtp_password_v4
      smtp_server                      = var.smtp_server
      smtp_port                        = var.smtp_port
      smtp_tls                         = "${var.smtp_tls}"
      from_email                       = var.from_email
      authentik_cookie_key_ssm_name    = var.authentik_cookie_key_ssm_name
      authentik_akadmin_email_ssm_name = var.authentik_akadmin_email_ssm_name
      authentik_akadmin_password       = var.authentik_akadmin_password_ssm_name
      sa_server_arn                    = module.authentik_server.iam_role_arn
      sa_worker_arn                    = module.authentik_worker.iam_role_arn
      host                             = var.host
      domain_name                      = var.domain_name
  })

}
