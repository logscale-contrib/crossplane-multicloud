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
  source = "${dirname(find_in_parent_folders())}/_modules/identity/authentik-sso-logscale/module/"
}


# ---------------------------------------------------------------------------------------------------------------------
# Locals are named constants that are reusable within the configuration.
# ---------------------------------------------------------------------------------------------------------------------
locals {
  tenant = yamldecode(file(find_in_parent_folders("tenant.yaml")))

}

dependency "dns_partition" {
  config_path = "${get_terragrunt_dir()}/../../../dns/"
}

dependency "authentik" {
  config_path = "${get_terragrunt_dir()}/../../../partition/identity/"
}

# ---------------------------------------------------------------------------------------------------------------------
# MODULE PARAMETERS
# These are the variables we have to pass in to use the module. This defines the parameters that are common across all
# environments.
# ---------------------------------------------------------------------------------------------------------------------
inputs = {
  admin_email = "ryan.faircloth@crowdstrike.com"
  app_name    = "logscale"
  token       = dependency.authentik.outputs.admin_token
  url         = dependency.authentik.outputs.url

  domain_name = dependency.dns_partition.outputs.zone_name
  host_prefix = "partition"
  tenant      = local.tenant.name

  management-cluster      = local.tenant.logscale.management-cluster
  management-organization = local.tenant.logscale.management-organization
  users                   = local.tenant.logscale.users

}
