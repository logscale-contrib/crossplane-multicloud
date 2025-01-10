
resource "random_password" "bootstrap_password" {
  length = 21
}
resource "random_password" "bootstrap_token" {
  length = 40
}

data "aws_secretsmanager_secret" "sso" {
  name = var.sso_secret
}

resource "kubernetes_secret" "bootstrap" {
  depends_on = []
  metadata {
    name      = "authentik-bootstrap"
    namespace = "identity"
  }

  data = {
    password = random_password.bootstrap_password.result
    token    = random_password.bootstrap_token.result
    email    = jsondecode(data.aws_secretsmanager_secret.secret_string)["akadminEmail"]

  }
  type = "Opaque"
}
