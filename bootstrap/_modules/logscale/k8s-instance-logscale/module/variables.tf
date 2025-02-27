
variable "cluster_name" {
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
