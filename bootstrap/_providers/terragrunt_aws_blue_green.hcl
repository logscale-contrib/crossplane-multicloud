# ---------------------------------------------------------------------------------------------------------------------
# TERRAGRUNT CONFIGURATION
# Terragrunt is a thin wrapper for Terraform that provides extra greenols for working with multiple Terraform modules,
# remote state, and locking: https://github.com/gruntwork-io/terragrunt
# ---------------------------------------------------------------------------------------------------------------------


locals {
  common     = yamldecode(file(find_in_parent_folders("common.yaml")))
  partition  = yamldecode(file(find_in_parent_folders("partition.yaml")))

  replication_role    = basename(get_terragrunt_dir())

  blue = split("-",local.replication_role)[0]
  blue_region = yamldecode(file(find_in_parent_folders("/aws/${local.blue}/region.yaml")))

  green = split("-",local.replication_role)[1]
  green_region = yamldecode(file(find_in_parent_folders("/aws/${local.green}/region.yaml")))

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
    variable "provider_aws_blue_region" {
      type = string
    }
    variable "provider_aws_green_region" {
      type = string
    }
    provider "aws" {
        region = var.provider_aws_region

        default_tags {
            tags = var.provider_aws_tags
        }
    }
    provider "aws" {
        alias = "blue"
        region = var.provider_aws_blue_region

        default_tags {
            tags = var.provider_aws_tags
        }
    }
    provider "aws" {
        alias = "green"
        region = var.provider_aws_green_region

        default_tags {
            tags = var.provider_aws_tags
        }
    }
EOF
}

inputs = {
  provider_aws_tags         = local.common.cloud.tags
  provider_aws_region       = local.partition.shared.provider.region
  provider_aws_blue_region  = local.blue_region.name
  provider_aws_green_region = local.green_region.name
}
