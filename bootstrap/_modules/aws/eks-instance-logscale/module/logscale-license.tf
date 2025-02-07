
data "kubectl_file_documents" "logscale-license" {
  content = templatefile(
    "./manifests/helm-releases/logscale-license.yaml",
    {
      logscale_namespace = var.logscale_namespace

  })
}

resource "kubectl_manifest" "logscale-license" {
  depends_on = [kubectl_manifest.namespaces]
  for_each   = data.kubectl_file_documents.logscale-license.manifests
  yaml_body  = each.value
}
