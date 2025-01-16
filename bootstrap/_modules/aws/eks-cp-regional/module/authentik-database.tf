
module "authentik_db_irsa" {

  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.52.2"

  role_name_prefix = var.authentik_namespace
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


resource "random_password" "authentik_db_password" {
  length  = 16
  special = true
}

module "authentik_db_password" {
  source = "terraform-aws-modules/secrets-manager/aws"

  # Secret
  name_prefix             = "authentik-db"
  recovery_window_in_days = 7

  # Policy
  create_policy       = true
  block_public_policy = true
  policy_statements = {

    read = {
      sid = "AllowAccountRead"
      principals = [{
        type = "AWS"
        identifiers = [
          module.authentik_db_irsa.iam_role_arn
        ]
      }]
      actions = [
        "secretsmanager:GetSecretValue",
        "secretsmanager:DescribeSecret"
      ]
      resources = ["*"]
    }
  }

  # Version
  # ignore_secret_changes = true
  secret_string = jsonencode({
    username = "authentik",
    password = random_password.authentik_db_password.result,
  })
  replica = {
    # Can set region as key
    replica = {
      # Or as attribute
      region = var.regions[var.db_state.blue["name"]].name
    }
  }

}

resource "kubectl_manifest" "db_green" {
  depends_on = [
    module.authentik_db_password
  ]
  count = (
    var.db_state.green["name"] == var.region_name
  ) ? 1 : 0

  yaml_body = templatefile("./manifests/helm-releases/database-${var.db_state.green["mode"]}.yaml",
    {
      role_arn        = module.authentik_db_irsa.iam_role_arn,
      region_name     = var.region_name,
      bucket_id       = var.data_bucket_id
      bucket_id_green = var.data_bucket_id_green
      bucket_id_blue  = var.data_bucket_id_blue
      green           = var.db_state.green["name"]
      blue            = var.db_state.blue["name"]
      primary         = var.db_state.green["replicaPrimary"]
      source          = var.db_state.green["replicaSource"]
  })

}

resource "kubectl_manifest" "db_green_backup" {
  depends_on = [kubectl_manifest.db_green]
  count = (
    var.db_state.green["backup"]
  ) ? 1 : 0

  yaml_body = templatefile("./manifests/helm-releases/database-backup.yaml",
    {
      region_name = var.db_state.green["name"]
  })
}


resource "kubectl_manifest" "db_blue" {
  depends_on = [
    module.authentik_db_password
  ]
  count = (
    var.db_state.blue["name"] == var.region_name
  ) ? 1 : 0

  yaml_body = templatefile("./manifests/helm-releases/database-${var.db_state.blue["mode"]}.yaml",
    {
      role_arn        = module.authentik_db_irsa.iam_role_arn,
      region_name     = var.region_name,
      bucket_id       = var.data_bucket_id
      bucket_id_green = var.data_bucket_id_green
      bucket_id_blue  = var.data_bucket_id_blue
      green           = var.db_state.green["name"]
      blue            = var.db_state.blue["name"]
      primary         = var.db_state.blue["replicaPrimary"]
      source          = var.db_state.blue["replicaSource"]
  })

}


resource "kubectl_manifest" "db_blue_backup" {
  depends_on = [kubectl_manifest.db_blue]
  count = (
    var.db_state.blue["backup"]
  ) ? 1 : 0

  yaml_body = templatefile("./manifests/helm-releases/database-backup.yaml",
    {
      region_name = var.db_state.blue["name"]
  })
}
