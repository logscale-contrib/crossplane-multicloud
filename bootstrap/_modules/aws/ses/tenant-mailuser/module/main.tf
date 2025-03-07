

resource "aws_iam_policy" "send_mail" {
  name   = "${var.email_user_name_prefix}-send-mail-${random_string.random.result}"
  policy = data.aws_iam_policy_document.send_mail.json
  tags = {

    git_file             = "bootstrap/_modules/aws/ses/tenant-mailuser/module/main.tf"
    git_last_modified_by = "ryan@dss-i.com"
    git_modifiers        = "ryan"
    git_org              = "logscale-contrib"
    git_repo             = "crossplane-multicloud"
    yor_name             = "send_mail"
    yor_trace            = "8a4cbeb4-f509-434b-8a57-4edeac3d42ee"
  }
}

locals {
  arnforraw = var.arn_raw
}
data "aws_iam_policy_document" "send_mail" {
  statement {
    actions = ["ses:SendRawEmail"]
    resources = [
      # aws_sesv2_email_identity.main.arn,
      local.arnforraw,
      var.aws_sesv2_configuration_set_arn
    ]
  }

}

resource "random_string" "random" {
  length  = 8
  special = false
  upper   = false
}

module "iam_ses_user" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-user"
  version = "5.53.0"

  name = "${var.email_user_name_prefix}-send-mail-${random_string.random.result}"

  create_iam_user_login_profile = false
  create_iam_access_key         = true
  password_reset_required       = false
  policy_arns = [
    aws_iam_policy.send_mail.arn
  ]
  tags = {

    git_file             = "bootstrap/_modules/aws/ses/tenant-mailuser/module/main.tf"
    git_last_modified_by = "ryan@dss-i.com"
    git_modifiers        = "ryan"
    git_org              = "logscale-contrib"
    git_repo             = "crossplane-multicloud"
    yor_name             = "iam_ses_user"
    yor_trace            = "966edade-6e8e-4164-9956-fcbff533e711"
  }
}
