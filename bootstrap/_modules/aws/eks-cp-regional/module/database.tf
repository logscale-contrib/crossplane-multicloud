
module "authentik_db_irsa" {

  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.52.2"

  role_name_prefix = "${var.authentik_namespace}"
  role_path        = var.iam_role_path

  role_policy_arns = {
    "object" = module.iam_iam-policy.arn
  }

  oidc_providers = {
    main = {
      provider_arn               = var.oidc_provider_arn
      namespace_service_accounts = ["${var.authentik_namespace}:${var.authentik_service_account}-${var.region_name}"]
    }
  }
}

module "iam_iam-policy" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version = "5.52.2"

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
          "${var.data_bucket_arn}/partition/authentik/*",
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
}

locals {
  db_green_template = var.region_name == var.db_primary ? "primary" : "secondary"
}

# resource "kubectl_manifest" "db_green" {
#   count = var.region_name == var.db_primary ? 1 : 0
  
#   yaml_body = templatefile("./manifests/helm-releases/database-primary.yaml",
#    { 
#         role_arn = module.authentik_db_irsa.iam_role_arn,
#         region_name = var.region_name,
#         bucket_id = var.data_bucket_id
#         bucket_id_green = var.data_bucket_id_green
#         bucket_id_blue  = var.data_bucket_id_blue
#         green = var.db_green
#         blue = var.db_blue
#         # cluster_name = module.eks.cluster_name 
#    })

# }

# resource "kubectl_manifest" "db-primary-backup" {
#   count =  var.region_name == var.db_primary ? 1 : 0
  
#   yaml_body = templatefile("./manifests/helm-releases/database-backup.yaml",
#    { 
#         region_name = var.region_name,
#    })

# }