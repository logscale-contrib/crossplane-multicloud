
variable "cluster_name" {
  type        = string
  description = "(optional) describe your variable"
}
variable "logscale_name" {

}

variable "logscale_namespace" {

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
