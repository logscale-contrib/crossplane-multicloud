
output "authentik_secrets_policy_arn" {
  value = resource.aws_iam_policy.authentik_secrets_policy.arn
}
output "authentik_token_ssm_name" {
  value = module.authentik_token.secret_name

}
output "authentik_cookie_key_ssm_name" {
  value = module.authentik_cookie_key.secret_name
}
output "authentik_akadmin_ssm_name" {
  value = module.authentik_akadmin.secret_name
}
output "authentik_akadmin_email_ssm_name" {
  value = "${var.ssm_path_prefix}/authentik/akadminEmail"
}
