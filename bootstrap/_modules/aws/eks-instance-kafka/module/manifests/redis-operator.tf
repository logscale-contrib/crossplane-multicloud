
resource "kubectl_manifest" "redis-operator" {

  yaml_body = templatefile("./manifests/helm-releases/redis-operator.yaml", {})
}
