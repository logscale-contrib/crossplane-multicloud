variable "iam_role_path" {

}

variable "oidc_provider_arn" {
  type        = string
  description = "(optional) describe your variable"
}

variable "logscale_namespace" {

}
variable "logscale_service_account" {
  default = "logscale"
}

variable "data_bucket_arn" {

}
variable "data_bucket_id" {

}
variable "bucket_prefix" {

}
