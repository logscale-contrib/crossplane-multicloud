
provider "authentik" {
  url   = var.url
  token = data.aws_secretsmanager_secret_version.secret-token.secret_string
}


terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.93.0"
    }
    authentik = {
      source  = "goauthentik/authentik"
      version = "2024.12.1"
    }

    random = {
      source  = "hashicorp/random"
      version = "3.7.1"
    }
    null = {
      source  = "hashicorp/null"
      version = ">= 3.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "4.0.6"
    }
  }
}
