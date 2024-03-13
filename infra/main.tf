provider "aws" {
  region = "eu-north-1"

  skip_metadata_api_check     = true
  skip_region_validation      = true
  skip_credentials_validation = true
}

module "geesefs" {
  source = "./modules/aws_fuse_benchmark"
  fs = "geesefs"
  user_data_template_path = "./configs/geesefs.sh"
  mount = "/tmp/geesefs"
}

module "goofys" {
  source = "./modules/aws_fuse_benchmark"
  fs = "goofys"
  user_data_template_path = "./configs/goofys.sh"
  mount = "/tmp/goofys"
}

module "rclone" {
  source = "./modules/aws_fuse_benchmark"
  fs = "rclone"
  user_data_template_path = "./configs/rclone.sh"
  mount = "/home/ubuntu/rclonemount"
}

module "s3fs" {
  source                  = "./modules/aws_fuse_benchmark"
  fs                      = "s3fs"
  user_data_template_path = "./configs/s3fs.sh"
  mount                   = "/tmp/s3/"
}

output "geesefs_names" {
  value = module.geesefs.public_ips
}

output "geesefs_job_buckets" {
  value = module.geesefs.job_buckets
}

output "goofys_names" {
  value = module.goofys.public_ips
}

output "goofys_job_buckets" {
  value = module.goofys.job_buckets
}

output "rclone_names" {
  value = module.rclone.public_ips
}

output "rclone_job_buckets" {
  value = module.rclone.job_buckets
}


output "s3fs_names" {
  value = module.s3fs.public_ips
}

output "s3fs_job_buckets" {
  value = module.s3fs.job_buckets
}
