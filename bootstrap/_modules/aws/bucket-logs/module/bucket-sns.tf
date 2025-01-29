module "AWSLogs" {
  source  = "terraform-aws-modules/sns/aws"
  version = "6.1.2"

  name            = "${var.name}-log-bucket-AWSLogs"
  use_name_prefix = true
  tags = {
    git_commit           = "N/A"
    git_file             = "bootstrap/_modules/aws/bucket-logs/module/bucket-sns.tf"
    git_last_modified_by = "ryan@dss-i.com"
    git_modifiers        = "ryan"
    git_org              = "logscale-contrib"
    git_repo             = "crossplane-multicloud"
    yor_name             = "AWSLogs"
    yor_trace            = "992874cc-bfdf-45ac-9627-4da0aa7fef8e"
  }
}
module "S3Logs" {
  source  = "terraform-aws-modules/sns/aws"
  version = "6.1.2"

  name            = "${var.name}-log-bucket-S3Logs"
  use_name_prefix = true
  tags = {
    git_commit           = "N/A"
    git_file             = "bootstrap/_modules/aws/bucket-logs/module/bucket-sns.tf"
    git_last_modified_by = "ryan@dss-i.com"
    git_modifiers        = "ryan"
    git_org              = "logscale-contrib"
    git_repo             = "crossplane-multicloud"
    yor_name             = "S3Logs"
    yor_trace            = "afc2e77c-0503-47f3-927c-06c254c0f46a"
  }
}
module "all_notifications" {
  source  = "terraform-aws-modules/s3-bucket/aws//modules/notification"
  version = "4.5.0"

  bucket = module.log_bucket.s3_bucket_id

  eventbridge = true

  sns_notifications = {
    AWSLogs = {
      topic_arn     = module.AWSLogs.topic_arn
      events        = ["s3:ObjectCreated:Put"]
      filter_prefix = "AWSLogs/"
    }
    S3Logs = {
      topic_arn     = module.S3Logs.topic_arn
      events        = ["s3:ObjectCreated:Put"]
      filter_prefix = "S3Logs/"
    }
  }
}
