provider "aws" {
  region  = "eu-north-1"
  profile = "kirill.bas"
}

variable "fuse_bench_mount_dir" {
  type    = string
  default = "/tmp/s3fs"
}

variable "fuse_bench_private_key_local_path" {
  type    = string
  default = "~/.ssh/fuse_bench"
}

variable "s3fs_benchmark_configs" {
  default = [
    "s3fs-one-job-sequential-read-42kb.sh",
    "s3fs-one-job-sequential-write-42kb.sh",
  ]
}

resource "aws_s3_bucket" "fusebenchresults" {
  bucket = "fusebenchresults"
}

resource "aws_iam_role" "fuse_benchmark_iam_role" {
  name               = "fuse_benchmark"
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
  name = "fuse_benchmark"
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

resource "aws_s3_bucket" "s3fs_benchmark" {
  bucket = "s3fsbenchmark"
}

resource "aws_instance" "s3fs_benchmark" {
  count = length(var.s3fs_benchmark_configs)
  ami                    = "ami-08a7297c0f05d943d"
  instance_type          = "t4g.nano"         # "c6g.4xlarge"
  iam_instance_profile   = aws_iam_instance_profile.fuse_benchmark_iam_profile.name
  vpc_security_group_ids = [aws_security_group.fuse_benchmark_allow_all.id]
  user_data              = file("${path.module}/configs/${var.s3fs_benchmark_configs[count.index]}")
  tags                   = {
    Name = var.s3fs_benchmark_configs[count.index]
  }
}

locals {
  instances_public_ips = [for instance in aws_instance.s3fs_benchmark : instance.public_ip]
}

output "ec2_s3fs_benchmark_public_ip" {
  value = local.instances_public_ips
}
