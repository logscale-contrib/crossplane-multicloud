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
  source = "${dirname(find_in_parent_folders())}/_modules/aws/eks-instance-logscale/module/"
}


# ---------------------------------------------------------------------------------------------------------------------
# Locals are named constants that are reusable within the configuration.
# ---------------------------------------------------------------------------------------------------------------------
locals {
  partition  = yamldecode(file(find_in_parent_folders("partition.yaml")))
  currentDir = get_terragrunt_dir()

  tenantName = regex("tenants/([^/]+)/", local.currentDir)[0]
  appName    = regex("tenants/[^/]+/([^/]+)/", local.currentDir)[0]

}

dependency "kubernetes_cluster" {
  config_path = "${get_terragrunt_dir()}/../../../../eks/"
}
dependency "bucket" {
  config_path = "${get_terragrunt_dir()}/../../../../bucket-data-dr/"
}
dependency "smtp" {
  config_path = "${get_terragrunt_dir()}/../../../../ses/"
}
# ---------------------------------------------------------------------------------------------------------------------
# MODULE PARAMETERS
# These are the variables we have to pass in to use the module. This defines the parameters that are common across all
# environments.
# ---------------------------------------------------------------------------------------------------------------------
inputs = {

  iam_role_path = local.partition.shared.provider.aws.iam_role_path

  oidc_provider_arn = dependency.kubernetes_cluster.outputs.oidc_provider_arn

  ssm_path_prefix = local.partition.shared.provider.aws.ssm_path_prefix
  region          = local.partition.shared.provider.aws.region
  regions         = local.partition.shared.provider.aws.regions

  data_bucket_arn = dependency.bucket.outputs.bucket_arn
  data_bucket_id  = dependency.bucket.outputs.bucket_id

  bucket_prefix = local.tenantName

  logscale_namespace = "${local.tenantName}-logscale"

}
smtp_server = dependency.smtp.outputs.smtp_server
smtp_port   = dependency.smtp.outputs.smtp_port
smtp_tls    = dependency.smtp.outputs.smtp_use_tls

arn_raw                         = dependency.smtp.outputs.arn_raw
aws_sesv2_configuration_set_arn = dependency.smtp.outputs.aws_sesv2_configuration_set_arn

from_email = "${local.tenantName}-logscale@${dependency.partition_zone.outputs.zone_name}"
