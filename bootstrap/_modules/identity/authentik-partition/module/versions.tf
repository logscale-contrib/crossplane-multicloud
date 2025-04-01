
data "aws_secretsmanager_secret" "token" {
  name = var.authentik_token_ssm_name
}
data "aws_secretsmanager_secret_version" "token" {
  secret_id = data.aws_secretsmanager_secret.token.id
}
provider "authentik" {
  url   = checkmate_http_health.up.url
  token = data.aws_secretsmanager_secret_version.token.secret_string
}

provider "dns-validation" {
  # Configuration options
}

provider "checkmate" {
  # Configuration options
}



terraform {
  required_version = ">= 1.0"

  required_providers {
    dns-validation = {
      source  = "ryanfaircloth/dns-validation"
      version = "0.2.3"
    }

    authentik = {
      source  = "goauthentik/authentik"
      version = "2025.2.0"
    }
    checkmate = {
      source  = "tetratelabs/checkmate"
      version = "1.8.4"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.7.1"
    }
    null = {
      source  = "hashicorp/null"
      version = ">= 3.0"
    }
  }
}
