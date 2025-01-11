variable "iam_role_path" {
  
}

variable "oidc_provider_arn" {
  type        = string
  description = "(optional) describe your variable"
}

variable "authentik_namespace" {
  type = string
  default = "authentik"
}

variable "authentik_service_account" {
  type        = string
  default = "authentik-db"
  description = "(optional) describe your variable"
  
}
variable "data_bucket_arn_green" {
  type        = string
  description = "(optional) describe your variable"  
}
variable "data_bucket_arn_blue" {
  type        = string
  description = "(optional) describe your variable"  
}