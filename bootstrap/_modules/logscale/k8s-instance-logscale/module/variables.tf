
variable "cluster_name" {
  type        = string
  description = "(optional) describe your variable"
}
variable "logscale_host" {
  type        = string
  description = "(optional) describe your variable"

}
variable "logscale_name" {

}

variable "logscale_namespace" {

}

variable "logscale_service_account_name" {
  type        = string
  description = "(optional) describe your variable"
  default     = "logscale"
}

variable "logscale_service_account_annotations" {
  type    = map(string)
  default = {}
}

variable "kafka_name" {
  type        = string
  description = "(optional) describe your variable"
}
variable "kafka_namespace" {
  type        = string
  description = "(optional) describe your variable"
}
variable "kafka_prefix_increment" {
  type        = string
  description = "(optional) describe your variable"
  default     = "0"
}

variable "logscale_buckets" {
  type = object({
    type     = string
    region   = string
    id       = string
    prefixes = map(string)
  })
}

variable "logscale_ingress_common" {
  type    = any
  default = {}
}

variable "logscale_sso" {
  type = any

}

variable "logscale_rootUser" {
  type        = string
  description = "(optional) describe your variable"
}

variable "logscale_smtp" {
  type = object({
    host     = string
    port     = number
    startTLS = bool
    username = string
    password = string
    sender   = string
  })
  description = "(optional) describe your variable"
}
