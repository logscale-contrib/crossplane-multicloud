variable "region" {
  type    = string
  default = "us-east-1"

}
variable "regions" {
  description = "Regions configuration"
  type = map(object({
    name   = string
    region = string
  }))
}


variable "iam_role_path" {

}

variable "oidc_provider_arn" {
  type        = string
  description = "(optional) describe your variable"
}
variable "ssm_path_prefix" {

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
