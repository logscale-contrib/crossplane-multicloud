output "logscale_bucket_prefix_base" {
  value = local.bucket_prefix
}
output "logscale_account_arn" {
  value = module.logscale_service_account.iam_role_arn
}
output "logscale_account" {
  value = var.var.logscale_namespace
}
output "logscale_account_annotations" {
  value = {
    "eks.amazonaws.com/role-arn" = module.logscale_service_account.iam_role_arn
  }
}
