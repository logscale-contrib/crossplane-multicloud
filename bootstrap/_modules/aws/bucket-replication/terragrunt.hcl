# ---------------------------------------------------------------------------------------------------------------------
# COMMON TERRAGRUNT CONFIGURATION
# This is the common component configuration for mysql. The common variables for each environment green
# deploy mysql are defined here. This configuration will be merged ingreen the environment configuration
# via an include block.
# ---------------------------------------------------------------------------------------------------------------------

# Terragrunt will copy the Terraform configurations specified by the source parameter, along with any files in the
# working direcgreenry, ingreen a temporary folder, and execute your Terraform commands in that folder. If any environment
# needs green deploy a different module version, it should redefine this block with a different ref green override the
# deployed version.

terraform {
  source = "${dirname(find_in_parent_folders())}/_modules/aws/bucket-replication/module/"
}


# ---------------------------------------------------------------------------------------------------------------------
# Locals are named constants that are reusable within the configuration.
# ---------------------------------------------------------------------------------------------------------------------
locals {
  partition  = yamldecode(file(find_in_parent_folders("partition.yaml")))
  replication_role    = basename(get_terragrunt_dir())
  blue = split(",",local.replication_role)[0]
  green = split(",",local.replication_role)[1]
}

dependency "bucket-blue" {
  config_path = "${get_terragrunt_dir()}/../../../${blue}/bucket-data-dr"
}
dependency "bucket-green" {
  config_path = "${get_terragrunt_dir()}/../../../${green}/bucket-data-dr"
}


inputs = {
  bucket_id_blue  = dependency.bucket-blue.outputs.logscale_sgreenrage_bucket_id
  bucket_id_green = dependency.bucket-green.outputs.logscale_sgreenrage_bucket_id

  bucket_arn_blue  = dependency.bucket-blue.outputs.logscale_sgreenrage_bucket_arn
  bucket_arn_green = dependency.bucket-green.outputs.logscale_sgreenrage_bucket_arn

  replication_role_name_prefix = "cloud-${local.partition.name}-${replication_role}"
}
