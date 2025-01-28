variable "region_name" {

}

variable "iam_role_path" {

}

variable "oidc_provider_arn" {
  type        = string
  description = "(optional) describe your variable"
}

variable "authentik_namespace" {
  type    = string
  default = "authentik"
}

variable "authentik_service_account" {
  type        = string
  default     = "authentik-db"
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

variable "regions" {
  description = "Regions configuration"
  type = map(object({
    name             = string
    region           = string
    az_exclude_names = list(string)
  }))
}

variable "db_state" {
  type = map(object({
    mode           = string
    name           = string
    backup         = bool
    replicaPrimary = string
    replicaSource  = string
  }))
}

variable "authentik_state" {
  type = map(object({
    mode = string
    name = string
    # backup         = bool
    # replicaPrimary = string
    # replicaSource  = string
  }))
}

variable "smtp_server" {
  type        = string
  description = "(optional) describe your variable"
}
variable "smtp_port" {
  type        = string
  default     = "587"
  description = "(optional) describe your variable"
}
variable "smtp_tls" {
  type        = bool
  default     = true
  description = "(optional) describe your variable"
}

variable "from_email" {
  type        = string
  description = "(optional) describe your variable"
}


variable "arn_raw" {

}

variable "aws_sesv2_configuration_set_arn" {

}

variable "authentik_cookie_key_policy_arn" {

}
variable "authentik_cookie_key_ssm_name" {

}
variable "authentik_akadmin_password_ssm_name" {

}
variable "authentik_akadmin_email_ssm_name" {

}
variable "domain_name" {

}
variable "host" {

}
