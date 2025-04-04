
module "authentik_db_irsa" {

  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.54.1"

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
  tags = {

    git_file             = "bootstrap/_modules/aws/eks-cp-regional/module/authentik-database.tf"
    git_last_modified_by = "ryan@dss-i.com"
    git_modifiers        = "ryan"
    git_org              = "logscale-contrib"
    git_repo             = "crossplane-multicloud"
    yor_name             = "authentik_db_irsa"
    yor_trace            = "3020f3b1-03a7-4ed6-ad91-ad905536aa1d"
  }
}

module "iam_iam-policy" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version = "5.54.1"

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
  tags = {

    git_file             = "bootstrap/_modules/aws/eks-cp-regional/module/authentik-database.tf"
    git_last_modified_by = "ryan@dss-i.com"
    git_modifiers        = "ryan"
    git_org              = "logscale-contrib"
    git_repo             = "crossplane-multicloud"
    yor_name             = "iam_iam-policy"
    yor_trace            = "822c1d56-45cf-4f84-861c-f358b428a187"
  }
}


resource "random_password" "authentik_db_password" {
  length  = 16
  special = true
}

resource "kubernetes_secret" "db_secret" {
  depends_on = [
    kubectl_manifest.namespaces
  ]
  metadata {
    name      = "authentik-db-authentik-instance"
    namespace = var.authentik_namespace
  }

  data = {
    username = "authentik"
    password = random_password.authentik_db_password.result
  }

  type = "kubernetes.io/basic-auth"
}

resource "kubectl_manifest" "db_green" {
  depends_on = [time_sleep.flux2repos, kubectl_manifest.flux2-releases]
  count = (
    var.db_state.green["name"] == var.region_name
  ) ? 1 : 0

  yaml_body = templatefile("./manifests/helm-releases/database-${var.db_state.green["mode"]}.yaml",
    {
      namespace       = var.authentik_namespace,
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
      namespace   = var.authentik_namespace,
      region_name = var.db_state.green["name"]
  })
}


resource "kubectl_manifest" "db_blue" {
  depends_on = [time_sleep.flux2repos, kubectl_manifest.flux2-releases]
  count = (
    var.db_state.blue["name"] == var.region_name
  ) ? 1 : 0

  yaml_body = templatefile("./manifests/helm-releases/database-${var.db_state.blue["mode"]}.yaml",
    {
      namespace       = var.authentik_namespace,
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
      namespace   = var.authentik_namespace,
      region_name = var.db_state.blue["name"]
  })
}
