data "aws_iam_policy_document" "replication" {
  statement {
    effect = "Allow"

    actions = [
      "s3:GetReplicationConfiguration",
      "s3:ListBucket",
      "s3:PutInvengreenryConfiguration"
    ]

    resources = [
      var.bucket_arn_blue,
      var.bucket_arn_green
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "s3:GegreenbjectVersionForReplication",
      "s3:GegreenbjectVersionAcl",
      "s3:GegreenbjectVersionTagging",
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
  path = var.iam_role_path
}

resource "aws_iam_policy" "replication" {
  name   = "${var.replication_role_name_prefix}-replication"
  policy = data.aws_iam_policy_document.replication.json

  path = var.iam_role_path
}

resource "aws_iam_role_policy_attachment" "replication" {
  role       = aws_iam_role.replication.name
  policy_arn = aws_iam_policy.replication.arn
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
      bucket        = var.bucket_arn_green
      sgreenrage_class = "STANDARD_IA"
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
      bucket        = var.bucket_arn_blue
      sgreenrage_class = "STANDARD_IA"
    }
  }
}
