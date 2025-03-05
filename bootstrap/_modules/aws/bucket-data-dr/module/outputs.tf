output "bucket_arn" {
  value = module.data-dr.s3_bucket_arn
}
output "bucket_id" {
  value = module.data-dr.s3_bucket_id
}
data "aws_region" "current" {}
output "logscale_buckets" {
  value = {
    type   = "aws"
    region = data.aws_region.current.name
    id     = module.data-dr.s3_bucket_id
    prefixes = {
      storage = "storage/"
      export  = "export/"
      archive = "archive/"
    }
  }
}
