module "ebs_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.54.1"


  role_name_prefix = "ebs_csi"
  role_path        = var.iam_role_path


  attach_ebs_csi_policy = true

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:ebs-csi-controller-sa"]
    }
  }
  tags = {

    git_file             = "bootstrap/_modules/aws/eks-base/module/eks-aws-csi-ebs.tf"
    git_last_modified_by = "ryan@dss-i.com"
    git_modifiers        = "ryan"
    git_org              = "logscale-contrib"
    git_repo             = "crossplane-multicloud"
    yor_name             = "ebs_irsa"
    yor_trace            = "b1385e30-422e-4e0a-8e37-67b90a8a0e09"
  }
}

resource "kubectl_manifest" "ebs" {
  depends_on = [
    helm_release.flux2,
    kubectl_manifest.flux2-repos,
    kubectl_manifest.karpenter
  ]
  yaml_body = templatefile("./manifests/helm-manifests/eks-aws-csi-ebs.yaml", { iam_role_arn = module.ebs_irsa.iam_role_arn })
}


resource "kubernetes_annotations" "remove_gp2_default" {
  depends_on = [kubectl_manifest.flux2-releases]

  api_version = "storage.k8s.io/v1"
  kind        = "StorageClass"
  metadata {
    name = "gp2"
  }
  annotations = {
    "storageclass.kubernetes.io/is-default-class" = "false"
  }
  force = true
}
