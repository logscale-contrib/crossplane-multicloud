# ---------------------------------------------------------------------------------------------------------------------
# TERRAGRUNT CONFIGURATION
# Terragrunt is a thin wrapper for Terraform that provides extra tools for working with multiple Terraform modules,
# remote state, and locking: https://github.com/gruntwork-io/terragrunt
# ---------------------------------------------------------------------------------------------------------------------


locals {
  partition = yamldecode(file(find_in_parent_folders("partition.yaml")))
  region    = basename(dirname("${get_terragrunt_dir()}/../../../"))
}


generate "provider_aws" {
  path      = "provider_aws.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<-EOF

    variable "provider_aws_tags" {
      type = map
    }
    variable "provider_aws_region" {
      type = string
    }
    provider "aws" {
        region = var.provider_aws_region

        default_tags {
            tags = var.provider_aws_tags
        }
    }
EOF
}




inputs = {
  provider_aws_tags   = local.partition.shared.provider.aws.tags
  provider_aws_region = local.partition.shared.provider.aws.regions[local.region].region
}
