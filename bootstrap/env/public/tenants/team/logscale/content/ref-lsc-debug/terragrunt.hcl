# ---------------------------------------------------------------------------------------------------------------------
# TERRAGRUNT CONFIGURATION
# This is the configuration for Terragrunt, a thin wrapper for Terraform that helps keep your code DRY and
# maintainable: https://github.com/gruntwork-io/terragrunt
# ---------------------------------------------------------------------------------------------------------------------

# ---------------------------------------------------------------------------------------------------------------------
# Include configurations that are common used across multiple environments.
# ---------------------------------------------------------------------------------------------------------------------

# Include the root `terragrunt.hcl` configuration. The root configuration contains settings that are common across all
# components and environments, such as how to configure remote state.
include "root" {
  path = find_in_parent_folders()
}
include "root" {
  path = "${dirname(find_in_parent_folders())}/_providers/terragrunt_aws_tenant_eks.hcl"
}


# Include the envcommon configuration for the component. The envcommon configuration contains settings that are common
# for the component across all environments.
include "module" {
  path   = "${dirname(find_in_parent_folders())}/_modules/logscale/content-ref-lsc-debug/terragrunt.hcl"
  expose = true
}

# ---------------------------------------------------------------------------------------------------------------------
# We don't need to override any of the common parameters for this environment, so we don't specify any inputs.
# ---------------------------------------------------------------------------------------------------------------------
