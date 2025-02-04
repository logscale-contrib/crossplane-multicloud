


# data "kubectl_path_documents" "flux2-releases" {
#   pattern = "./manifests/helm-releases/*.yaml"
#   vars = {
#     kafka_namespace    = var.kafka_namespace
#     cluster_name       = var.cluster_name
#     kafka_name         = var.kafka_name
#     logscale_namespace = var.logscale_namespace
#   }
# }

# resource "kubectl_manifest" "flux2-releases" {
#   depends_on = [kubectl_manifest.namespaces]

#   for_each  = data.kubectl_path_documents.flux2-releases.manifests
#   yaml_body = each.value
# }
