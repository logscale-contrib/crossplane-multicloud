module "alb_ing_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.54.1"


  role_name_prefix = "alb_ic"
  role_path        = var.iam_role_path

  attach_load_balancer_controller_policy = true

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:aws-load-balancer-controller"]
    }
  }
  tags = {

    git_file             = "bootstrap/_modules/aws/eks-base/module/eks-aws-ic-alb.tf"
    git_last_modified_by = "ryan@dss-i.com"
    git_modifiers        = "ryan"
    git_org              = "logscale-contrib"
    git_repo             = "crossplane-multicloud"
    yor_name             = "alb_ing_irsa"
    yor_trace            = "a908121c-36db-448f-8fcd-76fd03759e62"
  }
}

resource "kubectl_manifest" "alb_ic" {
  depends_on = [
    helm_release.flux2,
    kubectl_manifest.flux2-repos,
    kubectl_manifest.karpenter,
    time_sleep.karpenter
  ]
  yaml_body = templatefile("./manifests/helm-manifests/eks-aws-ic-alb.yaml", { iam_role_arn = module.alb_ing_irsa.iam_role_arn, cluster_name = module.eks.cluster_name })
}



resource "kubectl_manifest" "alb_ic_config" {
  depends_on = [
    helm_release.flux2,
    kubectl_manifest.flux2-repos,
    kubectl_manifest.karpenter,
    time_sleep.karpenter,
    kubectl_manifest.alb_ic
  ]
  yaml_body = templatefile("./manifests/helm-manifests/eks-aws-ic-alb-config.yaml", { log_s3_bucket_id = var.log_s3_bucket_id })

}
