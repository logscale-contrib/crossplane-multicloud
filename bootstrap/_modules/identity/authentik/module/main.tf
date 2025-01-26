data "aws_caller_identity" "current" {}

data "aws_canonical_user_id" "current" {}

module "authentik_cookie_key" {
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
  create_policy       = false
  block_public_policy = true


  # Version
  create_random_password = true
  random_password_length = 50
  # random_password_override_special = "!@#$%^&*()_+"

  # tags = local.tags
}

resource "aws_iam_policy" "authentik_secrets_policy" {
  name        = "authentik_read_authentik_secrets_policy"
  path        = var.iam_role_path
  description = "Read Authentik Secrets"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        "Effect" : "Allow",
        "Action" : [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ],
        "Resource" : [
          module.authentik_cookie_key.secret_arn,
          module.authentik_cookie_key.secret_replica[0].secret_arn
        ],
      },
    ]
  })
}
