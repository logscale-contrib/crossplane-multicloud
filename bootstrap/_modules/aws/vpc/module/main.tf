
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.19.0"

  name = var.name
  cidr = var.cidr

  azs             = var.azs
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets

  enable_nat_gateway     = true
  single_nat_gateway     = true
  enable_ipv6            = true
  create_egress_only_igw = true

  enable_dns_hostnames = true
  enable_dns_support   = true

  public_subnet_ipv6_prefixes                    = var.public_subnet_ipv6_prefixes
  public_subnet_assign_ipv6_address_on_creation  = true
  private_subnet_ipv6_prefixes                   = var.private_subnet_ipv6_prefixes
  private_subnet_assign_ipv6_address_on_creation = true


  public_subnet_tags = {
    "kubernetes.io/role/elb" = "1"
    # "kubernetes.io/cluster/${var.name}" = "shared"
  }

  private_subnet_tags = {
    # "kubernetes.io/cluster/${var.name}" = "shared"
    "kubernetes.io/role/internal-elb" = "1"
    # "karpenter.sh/discovery"            = "${var.name}"
  }


  enable_flow_log = true
  # create_flow_log_cloudwatch_iam_role             = true
  # create_flow_log_cloudwatch_log_group            = true
  flow_log_destination_arn  = var.log_s3_bucket_arn
  flow_log_destination_type = "s3"
  flow_log_file_format      = "plain-text"

  flow_log_cloudwatch_log_group_retention_in_days = 1
  tags = {

    git_file             = "bootstrap/_modules/aws/vpc/module/main.tf"
    git_last_modified_by = "ryan@dss-i.com"
    git_modifiers        = "ryan"
    git_org              = "logscale-contrib"
    git_repo             = "crossplane-multicloud"
    yor_name             = "vpc"
    yor_trace            = "acaff850-16d8-4fe2-ab35-9c8ba6c95d71"
  }
}

module "vpc_vpc-endpoints" {
  source  = "terraform-aws-modules/vpc/aws//modules/vpc-endpoints"
  version = "5.19.0"

  vpc_id = module.vpc.vpc_id

  create_security_group      = true
  security_group_name_prefix = "${var.name}-vpc-endpoints-"
  security_group_description = "VPC endpoint security group"
  security_group_rules = {
    ingress_https = {
      description = "HTTPS from VPC"
      cidr_blocks = [module.vpc.vpc_cidr_block]
    }
  }

  endpoints = {
    s3 = {
      service             = "s3"
      service_type        = "Gateway"
      private_dns_enabled = true
      route_table_ids     = module.vpc.private_route_table_ids
      policy = jsonencode({
        "Version" : "2012-10-17",
        "Statement" : [
          {
            "Sid" : "Allow-callers-from-specific-account",
            "Effect" : "Allow",
            "Principal" : "*",
            "Action" : "*",
            "Resource" : "*",
            "Condition" : {
              "StringEquals" : {
                "aws:PrincipalAccount" : data.aws_caller_identity.current.account_id
              }
            }
          }
        ]
      })

      tags = { Name = "s3-vpc-endpoint" }
    },
  }
  tags = {

    git_file             = "bootstrap/_modules/aws/vpc/module/main.tf"
    git_last_modified_by = "ryan@dss-i.com"
    git_modifiers        = "ryan"
    git_org              = "logscale-contrib"
    git_repo             = "crossplane-multicloud"
    yor_name             = "vpc_vpc-endpoints"
    yor_trace            = "37626dcd-bc99-4ea9-932b-5cbfb34f7c6e"
  }
}

data "aws_caller_identity" "current" {}



data "aws_iam_policy_document" "generic_endpoint_policy" {
  statement {
    effect    = "Allow"
    actions   = ["*"]
    resources = ["*"]

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    condition {
      test     = "StringNotEquals"
      variable = "aws:SourceVpc"

      values = [module.vpc.vpc_id]
    }
  }
}
