data "aws_caller_identity" "current" {}

data "aws_canonical_user_id" "current" {}


resource "aws_iam_policy" "logscale-license" {
  name        = "logscale-license_secrets_policy"
  path        = var.iam_role_path
  description = "Read logscale-license Secrets"

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
          "arn:aws:secretsmanager:${var.regions["green"]["region"]}:${data.aws_caller_identity.current.account_id}:secret:${var.ssm_path_prefix}/logscale/license*",
          "arn:aws:secretsmanager:${var.regions["blue"]["region"]}:${data.aws_caller_identity.current.account_id}:secret:${var.ssm_path_prefix}/logscale/license",
        ],
      },
    ]
  })
  tags = {

    git_file             = "bootstrap/_modules/identity/authentik/module/main.tf"
    git_last_modified_by = "ryan@dss-i.com"
    git_modifiers        = "ryan"
    git_org              = "logscale-contrib"
    git_repo             = "crossplane-multicloud"
    yor_name             = "logscale-license"
    yor_trace            = "25186846-35f6-4db0-8841-f3730dec9712"
  }
}


data "kubectl_file_documents" "logscale-license" {
  content = templatefile(
    "./manifests/helm-releases/logscale-license.yaml",
    {
      logscale_namespace = var.logscale_namespace
    }
  )
}

resource "kubectl_manifest" "logscale-license" {
  depends_on = [kubectl_manifest.namespaces]
  for_each   = data.kubectl_file_documents.logscale-license.manifests
  yaml_body  = each.value
}
