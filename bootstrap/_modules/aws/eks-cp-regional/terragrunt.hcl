# ---------------------------------------------------------------------------------------------------------------------
# COMMON TERRAGRUNT CONFIGURATION
# This is the common component configuration for mysql. The common variables for each environment to
# deploy mysql are defined here. This configuration will be merged into the environment configuration
# via an include block.
# ---------------------------------------------------------------------------------------------------------------------

# Terragrunt will copy the Terraform configurations specified by the source parameter, along with any files in the
# working directory, into a temporary folder, and execute your Terraform commands in that folder. If any environment
# needs to deploy a different module version, it should redefine this block with a different ref to override the
# deployed version.

terraform {
  //source = "git::https://github.com/terraform-aws-modules/terraform-aws-eks.git?ref=v19.21.0"
  source = "${dirname(find_in_parent_folders())}/_modules/aws/eks-cp-regional/module/"
}


# ---------------------------------------------------------------------------------------------------------------------
# Locals are named constants that are reusable within the configuration.
# ---------------------------------------------------------------------------------------------------------------------
locals {
  platform    = yamldecode(file(find_in_parent_folders("platform.yaml")))  
  
  partition    = yamldecode(file(find_in_parent_folders("partition.yaml")))  
  region = yamldecode(file(find_in_parent_folders("/aws/${local.partition.shared.sso.region}/region.yaml")))  
}

dependency "kubernetes_cluster" {
  config_path  = "${get_terragrunt_dir()}/../eks/"
}
dependency "bucket_green" {
  config_path  = "${get_terragrunt_dir()}/../../${local.partition.shared.sso.regions[0]}/bucket-data-dir/"
}
dependency "bucket_blue" {
  config_path  = "${get_terragrunt_dir()}/../../${local.partition.shared.sso.regions[1]}/bucket-data-dir/"
}

# dependency "partition_zone" {
#   config_path = "${get_terragrunt_dir()}/../../dns/"
# }
# dependency "smtp" {
#   config_path = "${get_terragrunt_dir()}/../../aws/${local.global.activeName}/ses/"
# }
# dependency "mailuser" {
#   config_path = "${get_terragrunt_dir()}/../identity-email/"
# }
# ---------------------------------------------------------------------------------------------------------------------
# MODULE PARAMETERS
# These are the variables we have to pass in to use the module. This defines the parameters that are common across all
# environments.
# ---------------------------------------------------------------------------------------------------------------------
inputs = {
  iam_role_path = local.platform.aws.iam_role_path

  oidc_provider_arn = dependency.kubernetes_cluster.outputs.oidc_provider_arn

  data_bucket_arn_green = dependency.bucket_green.outputs.bucket_arn
  data_bucket_arn_blue = dependency.bucket_blue.outputs.bucket_arn
  # domain_name = dependency.partition_zone.outputs.zone_name
  
  # smtp_user     = dependency.mailuser.outputs.smtp_user
  # smtp_password = dependency.mailuser.outputs.smtp_password
  # smtp_server   = dependency.smtp.outputs.smtp_server
  # from_email    = "NoReplyIdentityServices@${dependency.partition_zone.outputs.zone_name}"

}
