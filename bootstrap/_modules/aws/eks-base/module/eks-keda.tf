
module "keda_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.53.0"


  role_name_prefix = "keda-operator"

  role_path = var.iam_role_path

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["keda-operator:keda-operator"]
    }
  }
  tags = {

    git_file             = "bootstrap/_modules/aws/eks-base/module/eks-keda.tf"
    git_last_modified_by = "ryan@dss-i.com"
    git_modifiers        = "ryan"
    git_org              = "logscale-contrib"
    git_repo             = "crossplane-multicloud"
    yor_name             = "keda_irsa"
    yor_trace            = "6611d96e-c0d6-4e85-bbc2-bd24897fdf2b"
  }
}

resource "kubectl_manifest" "keda" {
  depends_on = [
    helm_release.flux2,
    kubectl_manifest.flux2-repos,
    kubectl_manifest.karpenter
  ]
  yaml_body = templatefile("./manifests/helm-manifests/eks-keda.yaml", { iam_role_arn = module.keda_irsa.iam_role_arn, cluster_name = module.eks.cluster_name })

}
