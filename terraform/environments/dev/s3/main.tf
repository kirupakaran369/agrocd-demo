provider "aws" {
  region = "eu-west-1"
}

module "s3" {
  source                  = "../../../modules/s3"
  block_public_acls       = var.block_public_acls
  block_public_policy     = var.block_public_policy
  ignore_public_acls      = var.ignore_public_acls
  restrict_public_buckets = var.restrict_public_buckets
  versioning              = var.versioning
  bucket_name             = var.bucket_name
}