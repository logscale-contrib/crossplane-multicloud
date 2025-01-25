module "secrets_manager" {
  source  = "terraform-aws-modules/secrets-manager/aws"
  version = "1.3.1"

  # Secret
  name_prefix             = "${var.ssm_path_prefix}/authentik-cookie-key"
  description             = "Cookie Signing Key must not change in DR"
  recovery_window_in_days = 0
  replica = {
    # Can set region as key
    another = {
      # Or as attribute
      region = var.regions["blue"]["region"]
    }
  }

  # Policy
  create_policy       = true
  block_public_policy = true
  policy_statements = {
    read = {
      sid = "AllowAccountRead"
      principals = [{
        type        = "AWS"
        identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
      }]
      actions   = ["secretsmanager:GetSecretValue"]
      resources = ["*"]
    }
  }

  # Version
  create_random_password = true
  random_password_length = 64
  # random_password_override_special = "!@#$%^&*()_+"

  # tags = local.tags
}
