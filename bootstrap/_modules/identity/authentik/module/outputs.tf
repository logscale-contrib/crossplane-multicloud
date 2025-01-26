
output "authentik_cookie_key_policy_arn" {
  value = module.authentik_cookie_key.policy_arn  
}
output "authentik_cookie_key_ssm_name" {
  value = module.authentik_cookie_key.secret_name    
}