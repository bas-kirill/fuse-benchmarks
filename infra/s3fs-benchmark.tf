provider "aws" {
  region  = "eu-north-1"
  profile = "kirill.bas"
}

data "aws_region" "current" {}

locals {
  formatted_timestamp = formatdate("YYYYMMDD-HHmmss", timestamp())
}

variable "fuse_bench_mount_dir" {
  type    = string
  default = "/tmp/s3fs"
}

variable "fuse_bench_private_key_local_path" {
  type    = string
  default = "~/.ssh/fuse_bench"
}

variable "s3fs_benchmark_config" {
  default = "./configs/s3fs.sh"
}

variable "s3_fs_benchmark_job_names" {
  type    = list(string)
  default = [
    "s3fs-1-job-30-write-42kb",
    "s3fs-1-job-70-read-42kb",
    "s3fs-1-job-sequential-read-42kb",
    "s3fs-1-job-sequential-write-42kb",
    "s3fs-16-jobs-random-read-42kb",
    "s3fs-16-jobs-random-write-42kb",
    "s3fs-16-jobs-sequential-read-42kb",
    "s3fs-16-jobs-sequential-write-42kb",
  ]
}

variable "s3_fs_numjobs" {
  type    = list(string)
  default = ["1", "1", "1", "1", "16", "16", "16", "16"]
}

variable "s3_fs_rw" {
  type    = list(string)
  default = ["rw", "rw", "read", "write", "randread", "randwrite", "read", "write"]
}

variable "s3_fs_rwmixwrite" {
  type    = list(string)
  default = ["30", "30", "50", "50", "50", "50", "50", "50"]
}

variable "s3_fs_rwmixread" {
  type    = list(string)
  default = ["70", "70", "50", "50", "50", "50", "50", "50"]
}

resource "aws_iam_role" "fuse_benchmark_iam_role" {
  name               = "fuse_benchmark-${local.formatted_timestamp}"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "ec2.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "fuse_benchmark_policy_attachment" {
  role       = aws_iam_role.fuse_benchmark_iam_role.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

resource "aws_iam_instance_profile" "fuse_benchmark_iam_profile" {
  name = "fuse_benchmark_${local.formatted_timestamp}"
  role = aws_iam_role.fuse_benchmark_iam_role.name
}

resource "aws_security_group" "fuse_benchmark_allow_all" {
  name        = "allow_all_traffic"
  description = "Allow all inbound and outbound traffic"

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_s3_bucket" "s3fs_benchmark_buckets" {
  count  = length(var.s3_fs_benchmark_job_names)
  bucket = replace(replace("${var.s3_fs_benchmark_job_names[count.index]}-${local.formatted_timestamp}", ".", ""), "-", "")
  # in another case s3fs can not mount
}

resource "aws_s3_bucket" "s3fs_benchmark_results" {
  bucket = "s3fsbenchmark-${local.formatted_timestamp}"
}

locals {
  instances_public_ips  = [for instance in aws_instance.s3fs_benchmark : instance.public_ip]
  s3_benchmarks_buckets = [for bucket in aws_s3_bucket.s3fs_benchmark_buckets : bucket.bucket]
}

resource "aws_instance" "s3fs_benchmark" {
  count                  = length(var.s3_fs_benchmark_job_names)
  ami                    = "ami-08a7297c0f05d943d"  # Ubuntu
  instance_type          = "t4g.nano" # "c6g.4xlarge"
  iam_instance_profile   = aws_iam_instance_profile.fuse_benchmark_iam_profile.name
  vpc_security_group_ids = [aws_security_group.fuse_benchmark_allow_all.id]
  user_data              = templatefile("${path.module}/configs/s3fs.sh", {
    AWS_REGION    = data.aws_region.current.name,
    MOUNT         = "/tmp/s3",
    BUCKET        = aws_s3_bucket.s3fs_benchmark_buckets[count.index].bucket,
    FIO_CONFIG    = "/home/ubuntu/s3fs.fio",
    IAM_ROLE      = aws_iam_role.fuse_benchmark_iam_role.name,
    REPORT_NAME   = replace(var.s3_fs_benchmark_job_names[count.index], ".sh", ".report"),
    RESULT        = "/home/ubuntu/${replace(var.s3_fs_benchmark_job_names[count.index], ".sh", ".report")}",
    REPORT_BUCKET = aws_s3_bucket.s3fs_benchmark_results.bucket,
    JOBNAME       = var.s3_fs_benchmark_job_names[count.index],
    NUMJOBS       = var.s3_fs_numjobs[count.index],
    FIORW         = var.s3_fs_rw[count.index],
    RWMIXWRITE    = var.s3_fs_rwmixwrite[count.index],
    RWMIXREAD     = var.s3_fs_rwmixread[count.index],
  })
  tags = {
    Name = var.s3_fs_benchmark_job_names[count.index]
  }
}

output "ec2_s3fs_benchmark_public_ip" {
  value = local.instances_public_ips
}

output "s3fs_benchmark_buckets" {
  value = local.s3_benchmarks_buckets
}

output "s3_benchmark_reports_bucket" {
  value = aws_s3_bucket.s3fs_benchmark_results.bucket
}

output "formatted_timestamp" {
  value = local.formatted_timestamp
}