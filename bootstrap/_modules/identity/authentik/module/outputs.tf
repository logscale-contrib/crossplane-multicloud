
output "authentik_cookie_key_policy_arn" {
  value = resource.aws_iam_policy.authentik_secrets_policy.arn
}
output "authentik_cookie_key_ssm_name" {
  value = module.authentik_cookie_key.secret_name    
}
output "authentik_authentik_akadmin_ssm_name" {
  value = module.authentik_akadmin.secret_name  
}