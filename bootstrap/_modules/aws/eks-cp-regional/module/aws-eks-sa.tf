
module "irsa" {

  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.52.1"

  role_name_prefix = "${var.authentik_namespace}"
  role_path        = var.iam_role_path

  role_policy_arns = {
    "object" = module.iam_iam-policy.arn
  }

  oidc_providers = {
    main = {
      provider_arn               = var.oidc_provider_arn
      namespace_service_accounts = ["${var.authentik_namespace}:${var.authentik_service_account}"]
    }
  }
}

module "iam_iam-policy" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version = "5.52.1"

  name_prefix = "${var.authentik_namespace}_${var.authentik_service_account}"
  path        = var.iam_role_path


  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "FullAccess",
        "Effect" : "Allow",
        "Action" : [
          "s3:PutObject",
          "s3:GetObject",
          "s3:ListBucket",
          "s3:DeleteObject"
        ],
        "Resource" : [
          "${var.data_bucket_arn_green}/partition/authentik/green/*",
          "${var.data_bucket_arn_blue}/partition/authentik/blue/*"
        ]
      },
      {
        "Sid" : "ListBucket",
        "Effect" : "Allow",
        "Action" : [
          "s3:ListBucket"
        ],
        "Resource" : [
          var.data_bucket_arn_green,
          var.data_bucket_arn_blue,
        ]
      }
    ]
  })
}


