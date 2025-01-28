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
  partition = yamldecode(file(find_in_parent_folders("partition.yaml")))
  region    = basename(dirname("${get_terragrunt_dir()}/../.."))

}

dependency "kubernetes_cluster" {
  config_path = "${get_terragrunt_dir()}/../eks/"
}
dependency "bucket" {
  config_path = "${get_terragrunt_dir()}/../bucket-data-dr/"
}
dependency "bucket_green" {
  config_path = "${get_terragrunt_dir()}/../../${local.partition.shared.sso.db.green.name}/bucket-data-dr/"
}
dependency "bucket_blue" {
  config_path = "${get_terragrunt_dir()}/../../${local.partition.shared.sso.db.blue.name}/bucket-data-dr/"
}

dependency "partition_zone" {
  config_path = "${get_terragrunt_dir()}/../../../dns/"
}
dependency "smtp" {
  config_path = "${get_terragrunt_dir()}/../ses/"
}

dependency "authentik" {
  config_path = "${get_terragrunt_dir()}/../../../partition/authentik/"
}


# ---------------------------------------------------------------------------------------------------------------------
# MODULE PARAMETERS
# These are the variables we have to pass in to use the module. This defines the parameters that are common across all
# environments.
# ---------------------------------------------------------------------------------------------------------------------
inputs = {

  region_name = local.partition.shared.provider.aws.regions[local.region].name

  iam_role_path = local.partition.shared.provider.aws.iam_role_path

  oidc_provider_arn = dependency.kubernetes_cluster.outputs.oidc_provider_arn

  data_bucket_arn = dependency.bucket.outputs.bucket_arn
  data_bucket_id  = dependency.bucket.outputs.bucket_id

  data_bucket_id_green = dependency.bucket_green.outputs.bucket_id
  data_bucket_id_blue  = dependency.bucket_blue.outputs.bucket_id
  
  regions = local.partition.shared.provider.aws.regions
  db_state = local.partition.shared.sso.db
  authentik_state= local.partition.shared.sso.authentik

  domain_name = dependency.partition_zone.outputs.zone_name
  host = "sso"

  smtp_server   = dependency.smtp.outputs.smtp_server
  smtp_port     = dependency.smtp.outputs.smtp_port
  smtp_tls      = dependency.smtp.outputs.smtp_use_tls

  arn_raw                         = dependency.smtp.outputs.arn_raw
  aws_sesv2_configuration_set_arn = dependency.smtp.outputs.aws_sesv2_configuration_set_arn

  from_email    = "NoReplyIdentityServices@${dependency.partition_zone.outputs.zone_name}"

  authentik_cookie_key_policy_arn = dependency.authentik.outputs.authentik_cookie_key_policy_arn
  authentik_cookie_key_ssm_name = dependency.authentik.outputs.authentik_cookie_key_ssm_name
  authentik_akadmin = dependency.authentik.outputs.authentik_akadmin_ssm_name
}
