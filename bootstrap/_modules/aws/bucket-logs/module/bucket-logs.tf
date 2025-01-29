

module "log_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "4.5.0"

  bucket_prefix = "${var.name}-logs"
  force_destroy = true

  control_object_ownership = true

  attach_elb_log_delivery_policy        = true
  attach_lb_log_delivery_policy         = true
  attach_access_log_delivery_policy     = true
  attach_deny_insecure_transport_policy = true
  attach_require_latest_tls_policy      = true

  access_log_delivery_policy_source_accounts = [data.aws_caller_identity.current.account_id]
  #   access_log_delivery_policy_source_buckets = [
  #     "arn:aws:s3:::${local.bucket_name}"
  #   ]

  versioning = {
    enabled = true
  }

  lifecycle_rule = [
    {
      id                                     = "logs"
      enabled                                = true
      abort_incomplete_multipart_upload_days = 7

      noncurrent_version_expiration = {
        days = 14
      }
    }
  ]

  server_side_encryption_configuration = {
    rule = {
      "apply_server_side_encryption_by_default" = {
        "kms_master_key_id" = ""
        "sse_algorithm" : "AES256"
      }
      bucket_key_enabled = true
    }
  }
  tags = {
    git_commit           = "cade0b1748f832748786ff55c3b553aab1897963"
    git_file             = "bootstrap/_modules/aws/bucket-logs/module/bucket-logs.tf"
    git_last_modified_by = "ryan@dss-i.com"
    git_modifiers        = "ryan"
    git_org              = "logscale-contrib"
    git_repo             = "crossplane-multicloud"
    yor_name             = "log_bucket"
    yor_trace            = "f0f410b0-b8bc-4b17-be9d-b7109905393b"
  }
}
