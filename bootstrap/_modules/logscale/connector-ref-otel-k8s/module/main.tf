
data "kubectl_path_documents" "flux2-releases" {
  pattern = "./manifests/flux-releases/*.yaml"
  vars = {
    logscale_namespace = var.logscale_namespace
    logscale_name      = var.logscale_name
    allowDataDeletion  = true
    prefix             = var.prefix
  }
}

resource "kubectl_manifest" "flux2-releases" {

  for_each  = data.kubectl_path_documents.flux2-releases.manifests
  yaml_body = each.value
}
