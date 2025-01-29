module "vpc_cni_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.52.2"

  role_name_prefix = "vpc_cni"
  role_path        = var.iam_role_path


  attach_vpc_cni_policy = true
  vpc_cni_enable_ipv6   = true

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:aws-node"]
    }
  }
  tags = {
    git_commit           = "N/A"
    git_file             = "bootstrap/_modules/aws/eks-base/module/eks-aws-cni-irsa.tf"
    git_last_modified_by = "ryan@dss-i.com"
    git_modifiers        = "ryan"
    git_org              = "logscale-contrib"
    git_repo             = "crossplane-multicloud"
    yor_name             = "vpc_cni_irsa"
    yor_trace            = "20f1d7b8-5c85-4448-9bbd-3d4f0189ae8e"
  }
}
