
data "kubectl_file_documents" "logscale" {
  content = templatefile(
    "./manifests/helm-releases/logscale.yaml",
    {
      kafka_prefix       = "${format("g%03s", counters_monotonic.kafka_prefix.value)}"
      logscale_name      = var.logscale_name
      logscale_namespace = var.logscale_namespace

      # namespace                = local.namespace
      # region                   = var.region
      # platformType             = "aws"
      # kafka_namespace          = var.kafka_namespace
      # tenant                   = var.tenant
      # kafka_name               = var.kafka_name
      # kafka_prefix             = "${format("g%03s", counters_monotonic.kafka_prefix.value)}"
      # bucket_prefix            = "${local.namespace}/"
      # bucket_storage           = var.logscale_current_storage_bucket_id
      # bucket_export            = var.logscale_export_bucket_id
      # bucket_archive           = var.logscale_archive_bucket_id
      # logscale_sa_arn          = module.irsa.iam_role_arn
      # logscale_sa_name         = var.service_account
      # logscale_license         = var.logscale_license
      # fqdn                     = local.fqdn
      # fqdn_ingest              = local.fqdn_ingest
      # saml_issuer              = var.saml_issuer
      # saml_signing_certificate = base64encode(var.saml_signing_certificate)
      # saml_url                 = var.saml_url
      # rootUser                 = var.LogScaleRoot
      # ingest_role_arn          = module.ingest-role.iam_role_arn
      # scim_token               = var.scim_token
      # smtp_server              = var.smtp_server
      # smtp_port                = var.smtp_port
      # smtp_use_tls             = var.smtp_use_tls
      # smtp_user                = var.smtp_user
      # smtp_password            = var.smtp_password
      # smtp_sender              = var.smtp_sender
  })
}

locals {
  logscale_template = yamldecode(values(data.kubectl_file_documents.logscale.manifests)[0])
  logscale_service_account_annotations = {
    spec = { values = {
      logscale = {
        serviceAccount = {
          name        = var.logscale_service_account_name
          create      = true
          annotations = var.logscale_service_account_annotations
        }
      }
    } }
  }
}

module "logscale_values" {
  source  = "cloudposse/config/yaml//modules/deepmerge"
  version = "1.0.2"

  maps = [
    local.logscale_template,
    local.logscale_service_account_annotations
  ]
}

resource "kubectl_manifest" "logscale" {
  yaml_body = yamlencode(module.logscale_values.merged)
}
