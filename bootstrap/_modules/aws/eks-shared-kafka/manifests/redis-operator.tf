
resource "kubectl_manifest" "redis-operator" {
  depends_on = [
    time_sleep.external_services
  ]
  yaml_body = templatefile("./manifests/helm-releases/redis-operator.yaml", {})
}
