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
  source = "${dirname(find_in_parent_folders())}/_modules/logscale/k8s-instance-logscale/module/"
}


# ---------------------------------------------------------------------------------------------------------------------
# Locals are named constants that are reusable within the configuration.
# ---------------------------------------------------------------------------------------------------------------------
locals {
  partition  = yamldecode(file(find_in_parent_folders("partition.yaml")))
  tenant     = yamldecode(file(find_in_parent_folders("tenant.yaml")))
  currentDir = get_terragrunt_dir()
  tenantName = regex("tenants/([^/]+)/", local.currentDir)[0]
  appName    = regex("tenants/[^/]+/([^/]+)/", local.currentDir)[0]


}

dependency "kubernetes_cluster" {
  config_path = "${find_in_parent_folders("${local.tenant.shared.provider.name}/${local.tenant.shared.provider.region}")}/eks/"
}
dependency "kubernetes_cluster_cp_auth" {
  config_path  = "${find_in_parent_folders("${local.tenant.shared.provider.name}/${local.tenant.shared.provider.region}")}/eks-cp-auth/"
  skip_outputs = true
}

dependency "kafka-instance" {
  config_path = "${find_in_parent_folders("${local.tenant.shared.provider.name}/${local.tenant.shared.provider.region}")}/k8s-shared-kafka/"
}

dependency "infra-logscale" {
  config_path = "${find_in_parent_folders("${local.tenant.shared.provider.name}/${local.tenant.shared.provider.region}")}/tenants/${local.tenantName}/logscale/instance/"
}

dependency "sso" {
  config_path  = "${get_terragrunt_dir()}/../sso/"
  skip_outputs = true
}

# ---------------------------------------------------------------------------------------------------------------------
# MODULE PARAMETERS
# These are the variables we have to pass in to use the module. This defines the parameters that are common across all
# environments.
# ---------------------------------------------------------------------------------------------------------------------
inputs = {
  cluster_name       = dependency.kubernetes_cluster.outputs.cluster_name
  kafka_namespace    = dependency.kafka-instance.outputs.kafka_namespace
  kafka_name         = dependency.kafka-instance.outputs.kafka_name
  logscale_name      = local.tenantName
  logscale_namespace = "${local.tenantName}-logscale"

  logscale_service_account_name        = dependency.infra-logscale.outputs.logscale_account
  logscale_service_account_annotations = dependency.infra-logscale.outputs.logscale_account_annotations

  logscale_buckets = dependency.infra-logscale.outputs.logscale_buckets

  logscale_host           = "logscale.${local.tenantName}.${local.partition.name}.${local.partition.dns.parent_domain}"
  logscale_ingress_common = dependency.infra-logscale.outputs.logscale_ingress_common
  logscale_sso            = dependency.sso.outputs.logscale_sso
}
