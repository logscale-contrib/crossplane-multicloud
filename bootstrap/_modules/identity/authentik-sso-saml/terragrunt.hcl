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
  source = "${dirname(find_in_parent_folders())}/_modules/identity/authentik-sso-saml/module/"
}


# ---------------------------------------------------------------------------------------------------------------------
# Locals are named constants that are reusable within the configuration.
# ---------------------------------------------------------------------------------------------------------------------
locals {
  partition = yamldecode(file(find_in_parent_folders("partition.yaml")))
  tenant    = yamldecode(file(find_in_parent_folders("tenant.yaml")))

  currentDir = get_terragrunt_dir()
  tenantName = regex("tenants/([^/]+)/", local.currentDir)[0]
  appName    = regex("tenants/[^/]+/([^/]+)/", local.currentDir)[0]

}

dependency "dns_partition" {
  config_path = "${get_terragrunt_dir()}/../../../../dns/"
}

dependency "authentik" {
  config_path = "${get_terragrunt_dir()}/../../../../partition/authentik/"
}
dependency "authentik-partition" {
  config_path = "${get_terragrunt_dir()}/../../../../partition/authentik-partition/"
}


# ---------------------------------------------------------------------------------------------------------------------
# MODULE PARAMETERS
# These are the variables we have to pass in to use the module. This defines the parameters that are common across all
# environments.
# ---------------------------------------------------------------------------------------------------------------------
inputs = {
  admin_email              = local.partition.logscale.rootUser
  appName                  = local.appName
  tenantName               = local.tenantName
  authentik_token_ssm_name = dependency.authentik.outputs.authentik_token_ssm_name
  url                      = dependency.authentik-partition.outputs.url

  domain_name = dependency.dns_partition.outputs.zone_name
  host_prefix = local.tenantName
  tenant      = local.tenant

  # management-cluster      = local.tenant.logscale.management-cluster
  # management-organization = local.tenant.logscale.management-organization
  # users                   = local.tenant.logscale.users

}
