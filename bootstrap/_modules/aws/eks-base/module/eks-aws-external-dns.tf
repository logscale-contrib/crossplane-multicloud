

module "edns_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.52.2"

  role_name_prefix = "external-dns"
  role_path        = var.iam_role_path

  attach_external_dns_policy = true

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["external-dns:external-dns-sa"]
    }
  }
  tags = {

    git_file             = "bootstrap/_modules/aws/eks-base/module/eks-aws-external-dns.tf"
    git_last_modified_by = "ryan@dss-i.com"
    git_modifiers        = "ryan"
    git_org              = "logscale-contrib"
    git_repo             = "crossplane-multicloud"
    yor_name             = "edns_irsa"
    yor_trace            = "b9289b05-26c4-49b1-9fd0-912d02f5be79"
  }
}

resource "kubectl_manifest" "external-dns" {
  depends_on = [
    helm_release.flux2,
    kubectl_manifest.flux2-repos,
    kubectl_manifest.karpenter,
    time_sleep.karpenter
  ]
  yaml_body = templatefile("./manifests/helm-manifests/eks-aws-external-dns.yaml", { iam_role_arn = module.edns_irsa.iam_role_arn })
}
