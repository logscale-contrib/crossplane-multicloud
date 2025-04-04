terraform {
  required_version = ">= 1.0"


  required_providers {
    dns-validation = {
      source  = "ryanfaircloth/dns-validation"
      version = "0.2.3"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "5.94.1"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.17.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.36.0"
    }
    kubectl = {
      source  = "alekc/kubectl"
      version = "2.1.3"
    }
    null = {
      source  = "hashicorp/null"
      version = ">= 3.0"
    }
  }
}

provider "dns-validation" {
  # Configuration options
}
