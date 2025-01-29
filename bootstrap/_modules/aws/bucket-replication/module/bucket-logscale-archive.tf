data "aws_iam_policy_document" "replication" {
  statement {
    effect = "Allow"

    actions = [
      "s3:GetReplicationConfiguration",
      "s3:ListBucket",
      "s3:PutInventoryConfiguration"
    ]

    resources = [
      var.bucket_arn_blue,
      var.bucket_arn_green
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "s3:GetObjectVersionForReplication",
      "s3:GetObjectVersionAcl",
      "s3:GetObjectVersionTagging",
    ]

    resources = [
      "${var.bucket_arn_blue}/*",
      "${var.bucket_arn_green}/*"
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "s3:ReplicateObject",
      "s3:ReplicateDelete",
      "s3:ReplicateTags",
    ]

    resources = [
      "${var.bucket_arn_blue}/*",
      "${var.bucket_arn_green}/*"
    ]
  }
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type = "Service"
      identifiers = [
        "s3.amazonaws.com",
        "batchoperations.s3.amazonaws.com"
      ]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "replication" {
  name_prefix = var.replication_role_name_prefix

  assume_role_policy = data.aws_iam_policy_document.assume_role.json
  path               = var.iam_role_path
  tags = {

    git_file             = "bootstrap/_modules/aws/bucket-replication/module/bucket-logscale-archive.tf"
    git_last_modified_by = "ryan@dss-i.com"
    git_modifiers        = "ryan"
    git_org              = "logscale-contrib"
    git_repo             = "crossplane-multicloud"
    yor_name             = "replication"
    yor_trace            = "0a83d95a-8fa4-4535-acf5-aa1973164c1a"
  }
}

resource "aws_iam_policy" "replication_policy" {
  name   = "blue-green-blue"
  policy = data.aws_iam_policy_document.replication.json

  path = var.iam_role_path

  tags = {

    git_file             = "bootstrap/_modules/aws/bucket-replication/module/bucket-logscale-archive.tf"
    git_last_modified_by = "ryan@dss-i.com"
    git_modifiers        = "ryan"
    git_org              = "logscale-contrib"
    git_repo             = "crossplane-multicloud"
    yor_name             = "replication_policy"
    yor_trace            = "cd9208f0-1b98-4da1-a074-7550ca6cf70a"
  }
}

resource "aws_iam_role_policy_attachment" "replication_policy_attachment" {
  role       = aws_iam_role.replication.name
  policy_arn = aws_iam_policy.replication_policy.arn
}

resource "aws_s3_bucket_replication_configuration" "blue_green" {
  provider = aws.blue

  role   = aws_iam_role.replication.arn
  bucket = var.bucket_id_blue

  rule {
    id     = "sync"
    status = "Enabled"

    filter {
      prefix = ""
    }

    delete_marker_replication {
      status = "Enabled"
    }

    destination {
      bucket = var.bucket_arn_green
    }
  }
}

resource "aws_s3_bucket_replication_configuration" "green_blue" {
  provider = aws.green

  role   = aws_iam_role.replication.arn
  bucket = var.bucket_id_green


  rule {
    id     = "sync"
    status = "Enabled"


    filter {
      prefix = ""
    }

    delete_marker_replication {
      status = "Enabled"
    }

    destination {
      bucket = var.bucket_arn_blue
    }
  }
}
