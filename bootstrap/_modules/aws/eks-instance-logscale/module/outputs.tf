output "logscale_bucket_prefix_base" {
  value = local.bucket_prefix
}
output "logscale_account_arn" {
  value = module.logscale_service_account.arn
}
