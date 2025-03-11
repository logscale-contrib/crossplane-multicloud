
module "otel_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.54.0"


  role_name_prefix = "otel-sa"
  role_path        = var.iam_role_path


  role_policy_arns = {
    "DescribeInstances" = module.otel-policy.arn
  }

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:otel-node-opentelemetry-collector"]
    }
  }
  tags = {

    git_file             = "bootstrap/_modules/aws/eks-base/module/eks-aws-otel-sa.tf"
    git_last_modified_by = "ryan@dss-i.com"
    git_modifiers        = "ryan"
    git_org              = "logscale-contrib"
    git_repo             = "crossplane-multicloud"
    yor_name             = "otel_irsa"
    yor_trace            = "124e2bac-5634-4fab-9f9d-a531cc40b54b"
  }
}



module "otel-policy" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version = "5.54.0"

  name_prefix = "otel"
  path        = var.iam_role_path


  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "DescribeInstances",
        "Effect" : "Allow",
        "Action" : [
          "ec2:DescribeInstances",
          "eks:DescribeCluster",
          "ec2:DescribeTags",
        ],
        "Resource" : [
          "*"
        ]
      }
    ]
  })
  tags = {

    git_file             = "bootstrap/_modules/aws/eks-base/module/eks-aws-otel-sa.tf"
    git_last_modified_by = "ryan@dss-i.com"
    git_modifiers        = "ryan"
    git_org              = "logscale-contrib"
    git_repo             = "crossplane-multicloud"
    yor_name             = "otel-policy"
    yor_trace            = "4d56095f-7978-427a-bded-81582f3fc4dc"
  }
}
