
module "karpenter" {
  source  = "terraform-aws-modules/eks/aws//modules/karpenter"
  version = "20.35.0"

  cluster_name      = module.eks.cluster_name
  cluster_ip_family = "ipv6"

  enable_irsa            = true
  irsa_oidc_provider_arn = module.eks.oidc_provider_arn

  iam_role_path      = var.iam_role_path
  iam_policy_path    = var.iam_role_path
  node_iam_role_path = var.iam_role_path
  # create_node_iam_role = false
  # # Since the nodegroup role will already have an access entry
  # create_access_entry = false
  # node_iam_role_arn    = module.eks.eks_managed_node_groups["system"].iam_role_arn

  # Used to attach additional IAM policies to the Karpenter node IAM role
  node_iam_role_additional_policies = {
    AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }

  irsa_namespace_service_accounts = ["kube-system:karpenter"]
  enable_v1_permissions           = true
  tags = {

    git_file             = "bootstrap/_modules/aws/eks-base/module/eks-karpenter.tf"
    git_last_modified_by = "ryan@dss-i.com"
    git_modifiers        = "ryan"
    git_org              = "logscale-contrib"
    git_repo             = "crossplane-multicloud"
    yor_name             = "karpenter"
    yor_trace            = "f4873e71-a0ee-4ce9-9463-02917cdaaba3"
  }
}

resource "kubectl_manifest" "karpenter" {
  depends_on = [
    time_sleep.flux2repos
  ]
  yaml_body = templatefile(
    "./manifests/helm-manifests/eks-karpenter.yaml",
    {
      cluster_name     = module.eks.cluster_name,
      cluster_endpoint = module.eks.cluster_endpoint
      queue_name       = module.karpenter.queue_name,
      iam_role_arn     = module.karpenter.iam_role_arn
    }
  )
}

locals {
  karpenter_subnets = [ # outside map with "prop" key and map value
    for subnet in var.subnets :
    { id = subnet }
  ]
}
resource "time_sleep" "karpenter" {
  depends_on       = [kubectl_manifest.karpenter]
  destroy_duration = "90s"
}
resource "kubectl_manifest" "node_classes" {
  depends_on = [
    time_sleep.karpenter
  ]
  yaml_body = templatefile(
    "./manifests/helm-manifests/eks-karpenter-nodeclasses.yaml",
    {
      node_iam_role_name     = module.karpenter.node_iam_role_name
      subnet_selector        = local.karpenter_subnets
      node_security_group_id = module.eks.node_security_group_id,
      cluster_name           = module.eks.cluster_name
    }
  )
}
resource "time_sleep" "node_classes" {
  depends_on       = [kubectl_manifest.node_classes]
  destroy_duration = "300s"
}
resource "kubectl_manifest" "node_pools" {
  depends_on = [
    time_sleep.node_classes
  ]
  yaml_body = templatefile(
    "./manifests/helm-manifests/eks-karpenter-nodepools.yaml",
    {
    }
  )
}
