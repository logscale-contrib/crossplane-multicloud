# ---------------------------------------------------------------------------------------------------------------------
# TERRAGRUNT CONFIGURATION
# Terragrunt is a thin wrapper for Terraform that provides extra tools for working with multiple Terraform modules,
# remote state, and locking: https://github.com/gruntwork-io/terragrunt
# ---------------------------------------------------------------------------------------------------------------------


locals {
  partition = yamldecode(file(find_in_parent_folders("partition.yaml")))
}


generate "provider_aws" {
  path      = "provider_aws.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<-EOF

    variable "provider_aws_tags" {
      type = map
    }
     provider "aws" {
        # Note this is hard coded for public partition AWS cloud "global"
        # Resources are generally managed here
        region = "us-east-1"
        default_tags {
            tags = var.provider_aws_tags
        }
    }
EOF
}




inputs = {
  provider_aws_tags             = local.partition.shared.provider.aws.tags
  provider_aws_eks_cluster_name = "${local.partition.name}-${local.partition.shared.provider.aws.region[local.region].region}"
}
