
locals {
  bucket_prefix = var.logscale_namespace == "partition-logscale" ? "partition/logscale" : "tenants/${var.logscale_namespace}/logscale"
}
module "logscale_service_account" {

  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.55.0"

  role_name_prefix = var.logscale_namespace
  role_path        = var.iam_role_path

  role_policy_arns = {
    "object"  = module.logscale_bucket_access.arn
    "license" = aws_iam_policy.logscale-license.arn
    # "ingest" = module.iam_iam-assume_ingest-base.arn
  }

  oidc_providers = {
    main = {
      provider_arn               = var.oidc_provider_arn
      namespace_service_accounts = ["${var.logscale_namespace}:${var.logscale_namespace}"]
    }
  }
  tags = {
    yor_name             = "logscale_service_account"
    yor_trace            = "413aeebf-c5ba-4419-b985-bf807e08e8c9"
    git_file             = "bootstrap/_modules/aws/eks-instance-logscale/module/aws-eks-sa.tf"
    git_last_modified_by = "ryan@dss-i.com"
    git_modifiers        = "ryan"
    git_org              = "logscale-contrib"
    git_repo             = "crossplane-multicloud"
  }
}

module "logscale_bucket_access" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version = "5.55.0"

  name_prefix = "${var.logscale_namespace}_${var.logscale_namespace}"
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
          "${var.data_bucket_arn}/${local.bucket_prefix}/*",
        ]
      },
      {
        "Sid" : "ListBucket",
        "Effect" : "Allow",
        "Action" : [
          "s3:ListBucket"
        ],
        "Resource" : [
          var.data_bucket_arn,
        ]
      }
    ]
  })
  tags = {
    yor_name             = "logscale_bucket_access"
    yor_trace            = "8f32e922-7883-4007-b10d-33080defd1d4"
    git_file             = "bootstrap/_modules/aws/eks-instance-logscale/module/aws-eks-sa.tf"
    git_last_modified_by = "ryan@dss-i.com"
    git_modifiers        = "ryan"
    git_org              = "logscale-contrib"
    git_repo             = "crossplane-multicloud"
  }
}


# module "iam_iam-assume_ingest-base" {
#   source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
#   version = "5.52.2"

#   name_prefix = "${var.logscale_namespace}_${var.logscale_namespace}-assume-ingest-base"
#   # path        = var.iam_policy_path


#   policy = jsonencode({
#     "Version" : "2012-10-17",
#     "Statement" : [
#       {
#         "Sid" : "FullAccess",
#         "Effect" : "Allow",
#         "Action" : [
#           "sts:AssumeRole"
#         ],
#         "Resource" : [
#           module.ingest-role.iam_role_arn
#         ]
#       },
#     ]
#   })
#   tags = {
#     yor_name  = "iam_iam-assume_ingest-base"
#     yor_trace = "67b15786-f8ea-46a0-b2a0-6876e29f7e0f"
#   }
# }
