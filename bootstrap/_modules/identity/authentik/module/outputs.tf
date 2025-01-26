
output "authentik_cookie_key_policy_arn" {
  value = module.secrets_manager.policy_arn  
}
output "authentik_cookie_key_ssm_name" {
  value = module.secrets_manager.secret_name    
}