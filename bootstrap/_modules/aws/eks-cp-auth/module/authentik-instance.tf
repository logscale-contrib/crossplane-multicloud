module "authentik_server" {

  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.54.0"

  role_name_prefix = "${var.authentik_namespace}-server"
  role_path        = var.iam_role_path

  role_policy_arns = {
    "authentik_secrets_policy_arn" = var.authentik_secrets_policy_arn
  }

  oidc_providers = {
    main = {
      provider_arn               = var.oidc_provider_arn
      namespace_service_accounts = ["${var.authentik_namespace}:authentik-server"]
    }
  }
  tags = {

    git_file             = "bootstrap/_modules/aws/eks-cp-auth/module/authentik-instance.tf"
    git_last_modified_by = "ryan@dss-i.com"
    git_modifiers        = "ryan"
    git_org              = "logscale-contrib"
    git_repo             = "crossplane-multicloud"
    yor_name             = "authentik_server"
    yor_trace            = "606c9e00-7ea8-4183-9cc3-e1c1e13ac8f1"
  }
}

module "authentik_worker" {

  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.54.0"

  role_name_prefix = "${var.authentik_namespace}-woker"
  role_path        = var.iam_role_path

  role_policy_arns = {
    "authentik_secrets_policy_arn" = var.authentik_secrets_policy_arn
  }

  oidc_providers = {
    main = {
      provider_arn               = var.oidc_provider_arn
      namespace_service_accounts = ["${var.authentik_namespace}:authentik-worker"]
    }
  }
  tags = {

    git_file             = "bootstrap/_modules/aws/eks-cp-auth/module/authentik-instance.tf"
    git_last_modified_by = "ryan@dss-i.com"
    git_modifiers        = "ryan"
    git_org              = "logscale-contrib"
    git_repo             = "crossplane-multicloud"
    yor_name             = "authentik_worker"
    yor_trace            = "e6bd4434-b407-4ebe-85db-97b8ffdbd852"
  }
}

resource "kubectl_manifest" "authentik_instance" {
  count = (
    var.authentik_state[var.region_name]["mode"] == "normal" || var.authentik_state[var.region_name]["mode"] == "bootstrap"
  ) ? 1 : 0
  depends_on = [time_sleep.flux2repos, kubectl_manifest.flux2-releases]
  yaml_body = templatefile("./manifests/helm-releases/authentik-${var.authentik_state[var.region_name]["mode"]}.yaml",
    {
      region_name                         = var.region_name
      namespace                           = var.authentik_namespace
      smtp_user                           = module.iam_ses_user.iam_access_key_id
      smtp_password                       = module.iam_ses_user.iam_access_key_ses_smtp_password_v4
      smtp_server                         = var.smtp_server
      smtp_port                           = var.smtp_port
      smtp_tls                            = "${var.smtp_tls}"
      from_email                          = var.from_email
      authentik_cookie_key_ssm_name       = var.authentik_cookie_key_ssm_name
      authentik_akadmin_email_ssm_name    = var.authentik_akadmin_email_ssm_name
      authentik_akadmin_password_ssm_name = var.authentik_akadmin_password_ssm_name_ssm_name
      authentik_token_ssm_name            = var.authentik_token_ssm_name
      sa_server_arn                       = module.authentik_server.iam_role_arn
      sa_worker_arn                       = module.authentik_worker.iam_role_arn
      host                                = var.host
      domain_name                         = var.domain_name
  })

}
