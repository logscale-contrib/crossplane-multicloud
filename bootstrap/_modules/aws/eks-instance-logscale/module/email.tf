

resource "aws_iam_policy" "send_mail" {
  name   = "logscale-send-mail-${random_string.random.result}"
  policy = data.aws_iam_policy_document.send_mail.json
  path   = var.iam_role_path
  tags = {

    git_file             = "bootstrap/_modules/aws/eks-instance-logscale/module/email.tf"
    git_last_modified_by = "ryan@dss-i.com"
    git_modifiers        = "ryan"
    git_org              = "logscale-contrib"
    git_repo             = "crossplane-multicloud"
    yor_name             = "send_mail"
    yor_trace            = "f5996138-7250-496a-af5f-eaf132e234a1"
  }
}

data "aws_iam_policy_document" "send_mail" {
  statement {
    actions = ["ses:SendRawEmail"]
    resources = [
      var.arn_raw,
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
  version = "5.54.1"

  name = "logscale-send-mail-${random_string.random.result}"

  create_iam_user_login_profile = false
  create_iam_access_key         = true
  password_reset_required       = false
  policy_arns = [
    aws_iam_policy.send_mail.arn
  ]
  path = var.iam_role_path
  tags = {

    git_file             = "bootstrap/_modules/aws/eks-instance-logscale/module/email.tf"
    git_last_modified_by = "ryan@dss-i.com"
    git_modifiers        = "ryan"
    git_org              = "logscale-contrib"
    git_repo             = "crossplane-multicloud"
    yor_name             = "iam_ses_user"
    yor_trace            = "1dcc6008-af20-4da5-b412-613e3ee64f59"
  }
}
