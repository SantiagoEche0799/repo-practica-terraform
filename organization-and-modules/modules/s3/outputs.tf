# Terraform file: outputs.tf for module s3

output "bucket_name" {
    description = "Nombre del bucket S3"
    value       = aws_s3_bucket.bucket.bucket
}

