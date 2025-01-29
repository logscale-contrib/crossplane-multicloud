variable "name" {
  type        = string
  description = "(optional) describe your variable"
}
variable "region" {
  description = "region configuration"
  type = map(object({
    name             = string
    region           = string
    az_exclude_names = list(string)
    kubernetes = object({
      node_groups = object({
        system = object({
          min_size     = number
          max_size     = number
          desired_size = number
        })
      })
    })
  }))
}
variable "cluster_version" {
  type        = string
  description = "(optional) describe your variable"
}
variable "component_versions" {
  type        = map(string)
  description = "(optional) describe your variable"
}
variable "vpc_id" {
  type        = string
  description = "(optional) describe your variable"
}
variable "subnets" {
  type        = list(string)
  description = "(optional) describe your variable"
}


variable "kms_key_administrators" {
  type        = list(string)
  description = "(optional) describe your variable"
}
variable "access_entries" {
  description = "Additional AWS IAM roles to add to the aws-auth configmap"
  type        = map(any)
  default     = null
}

variable "log_s3_bucket_id" {
  type        = string
  description = "(optional) describe your variable"
}

variable "iam_role_path" {
  type = string
}
