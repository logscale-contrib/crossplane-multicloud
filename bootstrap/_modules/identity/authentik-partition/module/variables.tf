variable "host" {

}
variable "domain_name" {

}

variable "authentik_token_ssm_name" {

}
variable "from_email" {
  type        = string
  description = "(optional) describe your variable"
}

variable "users" {
  type        = map(object({
    name  = string
    username = string
    email = string
  }))
  description = "(optional) describe your variable"
}
