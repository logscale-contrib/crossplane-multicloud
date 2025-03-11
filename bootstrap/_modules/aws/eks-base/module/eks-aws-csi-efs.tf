module "efs_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.54.0"


  role_name_prefix = "efs_csi"
  role_path        = var.iam_role_path

  attach_efs_csi_policy = true

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:efs-csi-controller-sa"]
    }
  }
  tags = {

    git_file             = "bootstrap/_modules/aws/eks-base/module/eks-aws-csi-efs.tf"
    git_last_modified_by = "ryan@dss-i.com"
    git_modifiers        = "ryan"
    git_org              = "logscale-contrib"
    git_repo             = "crossplane-multicloud"
    yor_name             = "efs_irsa"
    yor_trace            = "60d5daf4-ade2-4273-bf65-d7a97f65cf22"
  }
}

resource "kubectl_manifest" "efs" {
  depends_on = [
    helm_release.flux2,
    kubectl_manifest.flux2-repos,
    kubectl_manifest.karpenter,
    time_sleep.karpenter
  ]
  yaml_body = templatefile("./manifests/helm-manifests/eks-aws-csi-efs.yaml", { iam_role_arn = module.efs_irsa.iam_role_arn })
}
