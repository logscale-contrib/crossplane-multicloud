
module "irsa" {

  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.52.2"

  role_name_prefix = local.namespace
  # role_path        = var.iam_role_path

  role_policy_arns = {
    "object" = module.iam_iam-policy.arn
    "ingest" = module.iam_iam-assume_ingest-base.arn
  }

  oidc_providers = {
    main = {
      provider_arn               = var.oidc_provider_arn
      namespace_service_accounts = ["${local.namespace}:${var.service_account}"]
    }
  }
  tags = {
    yor_name  = "irsa"
    yor_trace = "413aeebf-c5ba-4419-b985-bf807e08e8c9"
  }
}

module "iam_iam-policy" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version = "5.52.2"

  name_prefix = "${local.namespace}_${var.service_account}"
  # path        = var.iam_policy_path


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
          "${var.logscale_storage_bucket_arn_blue}/${local.namespace}/*",
          "${var.logscale_storage_bucket_arn_green}/${local.namespace}/*",
          "${data.aws_s3_bucket.ls_archive.arn}/${local.namespace}/*",
          "${data.aws_s3_bucket.ls_export.arn}/${local.namespace}/*",
        ]
      },
      {
        "Sid" : "ListBucket",
        "Effect" : "Allow",
        "Action" : [
          "s3:ListBucket"
        ],
        "Resource" : [
          var.logscale_storage_bucket_arn_blue,
          var.logscale_storage_bucket_arn_green,
          data.aws_s3_bucket.ls_archive.arn,
          data.aws_s3_bucket.ls_export.arn,
        ]
      }
    ]
  })
  tags = {
    yor_name  = "iam_iam-policy"
    yor_trace = "8f32e922-7883-4007-b10d-33080defd1d4"
  }
}


module "iam_iam-assume_ingest-base" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version = "5.52.2"

  name_prefix = "${local.namespace}_${var.service_account}-assume-ingest-base"
  # path        = var.iam_policy_path


  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "FullAccess",
        "Effect" : "Allow",
        "Action" : [
          "sts:AssumeRole"
        ],
        "Resource" : [
          module.ingest-role.iam_role_arn
        ]
      },
    ]
  })
  tags = {
    yor_name  = "iam_iam-assume_ingest-base"
    yor_trace = "67b15786-f8ea-46a0-b2a0-6876e29f7e0f"
  }
}
