variable "iam_role_path" {

}


variable "ssm_path_prefix" {

}
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
