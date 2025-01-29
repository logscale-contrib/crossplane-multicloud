
module "data-dr" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "4.5.0"

  bucket_prefix = var.name
  # acl           = "private"

  control_object_ownership = true
  object_ownership         = "BucketOwnerEnforced"

  versioning = {
    enabled = true
  }

  logging = {
    target_bucket = var.logs_s3_bucket_id
    target_prefix = "S3Logs/"
  }

  lifecycle_rule = [
    {
      id                                     = "storage"
      enabled                                = true
      abort_incomplete_multipart_upload_days = 7

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

    git_file             = "bootstrap/_modules/aws/bucket-data-dr/module/bucket-logscale-data.tf"
    git_last_modified_by = "ryan@dss-i.com"
    git_modifiers        = "ryan"
    git_org              = "logscale-contrib"
    git_repo             = "crossplane-multicloud"
    yor_name             = "data-dr"
    yor_trace            = "4de72fb1-ea0c-4df8-b23b-6304d0168084"
  }
}
