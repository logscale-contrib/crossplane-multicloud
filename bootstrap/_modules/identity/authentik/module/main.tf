data "aws_caller_identity" "current" {}

data "aws_canonical_user_id" "current" {}

module "authentik_cookie_key" {
  source  = "terraform-aws-modules/secrets-manager/aws"
  version = "1.3.1"

  # Secret
  name_prefix             = "${var.ssm_path_prefix}/authentik/cookie-key-"
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
  create_random_password           = true
  random_password_length           = 50
  random_password_override_special = ""

  # tags = local.tags
  tags = {
    git_commit           = "cade0b1748f832748786ff55c3b553aab1897963"
    git_file             = "bootstrap/_modules/identity/authentik/module/main.tf"
    git_last_modified_by = "ryan@dss-i.com"
    git_modifiers        = "ryan"
    git_org              = "logscale-contrib"
    git_repo             = "crossplane-multicloud"
    yor_name             = "authentik_cookie_key"
    yor_trace            = "20024117-7ce2-4f6c-b420-f7a843039a71"
  }
}


module "authentik_akadmin" {
  source  = "terraform-aws-modules/secrets-manager/aws"
  version = "1.3.1"

  # Secret
  name_prefix             = "${var.ssm_path_prefix}/authentik/akadminPassword-"
  description             = "Initial AKAdmin Password"
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
  create_random_password           = true
  random_password_length           = 21
  random_password_override_special = ""

  # tags = local.tags
  tags = {
    git_commit           = "cade0b1748f832748786ff55c3b553aab1897963"
    git_file             = "bootstrap/_modules/identity/authentik/module/main.tf"
    git_last_modified_by = "ryan@dss-i.com"
    git_modifiers        = "ryan"
    git_org              = "logscale-contrib"
    git_repo             = "crossplane-multicloud"
    yor_name             = "authentik_akadmin"
    yor_trace            = "90505d57-0f57-4934-9111-0c063020afbc"
  }
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
          "arn:aws:secretsmanager:${var.regions["green"]["region"]}:${data.aws_caller_identity.current.account_id}:secret:${var.ssm_path_prefix}/authentik/cookie-key*",
          "arn:aws:secretsmanager:${var.regions["blue"]["region"]}:${data.aws_caller_identity.current.account_id}:secret:${var.ssm_path_prefix}/authentik/cookie-key*",
          "arn:aws:secretsmanager:${var.regions["green"]["region"]}:${data.aws_caller_identity.current.account_id}:secret:${var.ssm_path_prefix}/authentik/akadminPassword*",
          "arn:aws:secretsmanager:${var.regions["blue"]["region"]}:${data.aws_caller_identity.current.account_id}:secret:${var.ssm_path_prefix}/authentik/akadminPassword*",
          "arn:aws:secretsmanager:${var.regions["green"]["region"]}:${data.aws_caller_identity.current.account_id}:secret:${var.ssm_path_prefix}/authentik/akadminEmail*",
          "arn:aws:secretsmanager:${var.regions["blue"]["region"]}:${data.aws_caller_identity.current.account_id}:secret:${var.ssm_path_prefix}/authentik/akadminEmail*"
        ],
      },
    ]
  })
  tags = {
    git_commit           = "cade0b1748f832748786ff55c3b553aab1897963"
    git_file             = "bootstrap/_modules/identity/authentik/module/main.tf"
    git_last_modified_by = "ryan@dss-i.com"
    git_modifiers        = "ryan"
    git_org              = "logscale-contrib"
    git_repo             = "crossplane-multicloud"
    yor_name             = "authentik_secrets_policy"
    yor_trace            = "25186846-35f6-4db0-8841-f3730dec9712"
  }
}
