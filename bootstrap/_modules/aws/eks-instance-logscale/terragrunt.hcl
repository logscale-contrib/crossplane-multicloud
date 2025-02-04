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
  partition = yamldecode(file(find_in_parent_folders("partition.yaml")))
  region    = basename(dirname("${get_terragrunt_dir()}/../.."))
}

dependency "kubernetes_cluster" {
  config_path = "${get_terragrunt_dir()}/../eks/"
}
dependency "kubernetes_cluster_cp_auth" {
  config_path  = "${get_terragrunt_dir()}/../eks-cp-auth/"
  skip_outputs = true
}

dependency "authentik-partition" {
  config_path  = "${get_terragrunt_dir()}/../../../partition/authentik-partition/"
  skip_outputs = true
}

dependency "kafka-instance" {
  config_path = "${get_terragrunt_dir()}/../eks-instance-kafka/"
}

# ---------------------------------------------------------------------------------------------------------------------
# MODULE PARAMETERS
# These are the variables we have to pass in to use the module. This defines the parameters that are common across all
# environments.
# ---------------------------------------------------------------------------------------------------------------------
inputs = {
  cluster_name = dependency.kubernetes_cluster.outputs.cluster_name
  namespace    = dependency.kafka-instance.outputs.namespace
  kafka_name   = dependency.kafka-instance.outputs.kafka_name
}
