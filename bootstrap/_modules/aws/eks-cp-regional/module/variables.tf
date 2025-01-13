variable "region_name" {
  
}

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
variable "data_bucket_id" {
  type        = string
  description = "(optional) describe your variable"  
}
variable "data_bucket_arn" {
  type        = string
  description = "(optional) describe your variable"  
}

variable "data_bucket_id_green" {
  
}
variable "data_bucket_id_blue" {
  
}

variable "db_state" {
  type = map(object({
    mode   = string
    name_prefix = string
    replicaPrimary     = string
    replicaSource      = string
  }))
}
