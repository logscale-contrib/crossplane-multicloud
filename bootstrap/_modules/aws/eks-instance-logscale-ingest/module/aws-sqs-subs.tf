
module "sqs_awslogs" {
  source  = "terraform-aws-modules/sqs/aws"
  version = "4.3.1"

  name            = "${var.tenant}-awslogs"
  use_name_prefix = true

  create_queue_policy = true

  queue_policy_statements = {
    sns = {
      sid     = "SNSPublish"
      actions = ["sqs:SendMessage"]

      principals = [
        {
          type        = "Service"
          identifiers = ["sns.amazonaws.com"]
        }
      ]

      conditions = [{
        test     = "ArnEquals"
        variable = "aws:SourceArn"
        values   = [var.regional_sns_topic_arn]
      }]
    }
    logscale = {
      sid = "logscale"
      actions = [
        "sqs:ReceiveMessage",
        "sqs:GetQueueAttributes",
        "sqs:DeleteMessage",
        "sqs:ChangeMessageVisibility"
      ]
      principals = [
        {
          type        = "AWS"
          identifiers = [module.ingest-role-actor.iam_role_arn]
        }
      ]
    }
  }

  tags = {
    yor_name             = "sqs_awslogs"
    yor_trace            = "998d31ea-494b-4caf-b2a0-7695fd8026d5"
    git_file             = "bootstrap/_modules/aws/eks-instance-logscale-ingest/module/aws-sqs-subs.tf"
    git_last_modified_by = "ryan@dss-i.com"
    git_modifiers        = "ryan"
    git_org              = "logscale-contrib"
    git_repo             = "crossplane-multicloud"
  }
}

resource "aws_sns_topic_subscription" "aws_logs" {
  protocol             = "sqs"
  raw_message_delivery = true
  topic_arn            = var.regional_sns_topic_arn
  endpoint             = module.sqs_awslogs.queue_arn
}


module "sqs_s3logs" {
  source  = "terraform-aws-modules/sqs/aws"
  version = "4.3.1"

  name            = "${var.tenant}-s3logs"
  use_name_prefix = true

  create_queue_policy = true

  queue_policy_statements = {
    sns = {
      sid     = "SNSPublish"
      actions = ["sqs:SendMessage"]

      principals = [
        {
          type        = "Service"
          identifiers = ["sns.amazonaws.com"]
        }
      ]
      conditions = [{
        test     = "ArnEquals"
        variable = "aws:SourceArn"
        values   = [var.regional_sns_topic_arn]
      }]
    }
    logscale = {
      sid = "logscale"
      actions = [
        "sqs:ReceiveMessage",
        "sqs:GetQueueAttributes",
        "sqs:DeleteMessage",
        "sqs:ChangeMessageVisibility"
      ]
      principals = [
        {
          type        = "AWS"
          identifiers = [module.ingest-role-actor.iam_role_arn]
        }
      ]
    }
  }

  tags = {
    yor_name             = "sqs_s3logs"
    yor_trace            = "69501bc7-bbae-4392-b68c-84b1799cb26b"
    git_file             = "bootstrap/_modules/aws/eks-instance-logscale-ingest/module/aws-sqs-subs.tf"
    git_last_modified_by = "ryan@dss-i.com"
    git_modifiers        = "ryan"
    git_org              = "logscale-contrib"
    git_repo             = "crossplane-multicloud"
  }
}

resource "aws_sns_topic_subscription" "aws_s3logs" {
  protocol             = "sqs"
  raw_message_delivery = true
  topic_arn            = var.regional_sns_topic_arn
  endpoint             = module.sqs_s3logs.queue_arn
}
