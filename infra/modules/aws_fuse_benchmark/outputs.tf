output "public_ips" {
  value = [for instance in aws_instance.server : instance.public_ip]
}

output "job_buckets" {
  value = [for bucket in aws_s3_bucket.job_bucket : bucket.bucket]
}
