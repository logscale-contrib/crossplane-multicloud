
data "kubectl_path_documents" "namespaces" {
  pattern = "./manifests/namespaces/*.yaml"
  vars = {
    namespace = var.namespace
  }
}

resource "kubectl_manifest" "namespaces" {
  for_each  = data.kubectl_path_documents.namespaces.manifests
  yaml_body = each.value
}
