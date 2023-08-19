output "bucket_name" {
    description = "The name of the created S3 bucket"
    value       = module.s3.my_bucket.id
}