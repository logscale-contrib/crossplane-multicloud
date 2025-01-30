


data "kubectl_path_documents" "flux2-releases" {
  pattern = "./manifests/helm-releases/*.yaml"
  vars = {
    namespace    = var.namespace
    cluster_name = var.cluster_name
    kafka_name   = var.kafka_name
  }
}

resource "kubectl_manifest" "flux2-releases" {
  depends_on = [kubectl_manifest.namespaces]

  for_each  = data.kubectl_path_documents.flux2-releases.manifests
  yaml_body = each.value
}
