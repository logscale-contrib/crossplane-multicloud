
data "aws_secretsmanager_secret" "token" {
  name = var.authentik_token_ssm_name
}
data "aws_secretsmanager_secret_version" "token" {
  secret_id = data.aws_secretsmanager_secret.token.id
}
provider "authentik" {
  url   = "https://${var.host}.${var.domain_name}"
  token = data.aws_secretsmanager_secret_version.token.secret_string
}


terraform {
  required_version = ">= 1.0"

  required_providers {
    authentik = {
      source  = "goauthentik/authentik"
      version = "2024.12.0"
    }

    random = {
      source  = "hashicorp/random"
      version = "3.6.3"
    }
    null = {
      source  = "hashicorp/null"
      version = ">= 3.0"
    }
  }
}
