resource "kubectl_manifest" "db" {
  
  yaml_body = templatefile("./manifests/helm-manifests/database.yaml",
   { 
        # iam_role_arn = module.keda_irsa.iam_role_arn,
        # cluster_name = module.eks.cluster_name 
   })

}
