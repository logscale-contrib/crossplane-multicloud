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
  source = "${dirname(find_in_parent_folders())}/_modules/logscale/connector-ref-otel-k8s/module/"
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
dependency "logscale" {
  config_path  = "${get_terragrunt_dir()}/../../../../../../tenants/${local.tenantName}/logscale/instance/"
  skip_outputs = true
}

# ---------------------------------------------------------------------------------------------------------------------
# MODULE PARAMETERS
# These are the variables we have to pass in to use the module. This defines the parameters that are common across all
# environments.
# ---------------------------------------------------------------------------------------------------------------------
inputs = {
  logscale_name      = local.tenantName
  logscale_namespace = "${local.tenantName}-logscale"
  prefix             = local.tenant.logscale.content.otelK8s.prefix
}
