provider "aws" {
  region  = "eu-north-1"
  profile = "kirill.bas"
}

data "aws_region" "current" {}

variable "ubuntu" {
  type    = string
  default = "ami-08a7297c0f05d943d"
}

variable "instance_type" {
  type    = string
  default = "t4g.nano"
  # "c6g.4xlarge" #
}

variable "fio_jobs" {
  type    = string
  default = <<JSON
{
  "1-job-sequential-read": {
    "numjobs": "1",
    "rw": "read"
  },
  "1-job-sequential-write": {
    "numjobs": "1",
    "rw": "write"
  },
  "1-job-70-read": {
    "numjobs": "1",
    "rw": "rw",
    "rwmixwrite": "30",
    "rwmixread": "70"
  },
  "1-job-30-write": {
    "numjobs": "1",
    "rw": "rw",
    "rwmixwrite": "30",
    "rwmixread": "70"
  },
  "1-job-random-read": {
    "numjobs": "1",
    "rw": "randread"
  },
  "1-job-random-write": {
    "numjobs": "1",
    "rw": "randwrite"
  },
  "16-job-sequential-read": {
    "numjobs": "16",
    "rw": "read"
  },
  "16-job-sequential-write": {
    "numjobs": "16",
    "rw": "write"
  },
  "16-job-70-read": {
    "numjobs": "16",
    "rw": "rw",
    "rwmixwrite": "30",
    "rwmixread": "70"
  },
  "16-job-30-write": {
    "numjobs": "16",
    "rw": "rw",
    "rwmixwrite": "30",
    "rwmixread": "70"
  },
  "16-job-random-read": {
    "numjobs": "16",
    "rw": "randread"
  },
  "16-job-random-write": {
    "numjobs": "16",
    "rw": "randwrite"
  }
}
JSON
}

locals {
  formatted_timestamp = formatdate("YYYYMMDD-HHmmss", timestamp())
  fio_jobs_json = jsondecode(var.fio_jobs)
  fio_job_names = keys(local.fio_jobs_json)
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

resource "aws_s3_bucket" "s3fs_buckets" {
  count  = length(local.fio_job_names)
  bucket = replace("s3fs-${local.fio_job_names[count.index]}-${local.formatted_timestamp}", "-", "")
}

resource "aws_s3_bucket" "reports" {
  bucket = "fuse-benchmarks-${local.formatted_timestamp}"
}

locals {
  instances_public_ips  = [for instance in aws_instance.s3fs_42kb : instance.public_ip]
  s3_benchmarks_buckets = [for bucket in aws_s3_bucket.goofys_buckets : bucket.bucket]
}

resource "aws_instance" "s3fs_42kb" {
  count                  = length(local.fio_job_names)
  ami                    = var.ubuntu
  instance_type          = var.instance_type
  iam_instance_profile   = aws_iam_instance_profile.fuse_benchmark_iam_profile.name
  vpc_security_group_ids = [aws_security_group.fuse_benchmark_allow_all.id]
  user_data              = templatefile("${path.module}/configs/s3fs.sh", {
    AWS_REGION    = data.aws_region.current.name,
    MOUNT         = "/tmp/s3",
    BUCKET        = aws_s3_bucket.goofys_buckets[count.index].bucket,
    FIO_CONFIG    = "/home/ubuntu/s3fs.fio",
    IAM_ROLE      = aws_iam_role.fuse_benchmark_iam_role.name,
    REPORT_NAME   = "s3fs-${local.fio_job_names[count.index]}-42kb.report",
    RESULT        = "/home/ubuntu/s3fs-${local.fio_job_names[count.index]}-42kb.report",
    REPORT_BUCKET = aws_s3_bucket.reports.bucket,
    JOBNAME       = local.fio_job_names[count.index],
    NUMJOBS       = local.fio_jobs_json[local.fio_job_names[count.index]]["numjobs"],
    FIORW         = local.fio_jobs_json[local.fio_job_names[count.index]]["rw"],
    RWMIXWRITE    = lookup(local.fio_jobs_json[local.fio_job_names[count.index]], "rwmixwrite", 50),
    RWMIXREAD     = lookup(local.fio_jobs_json[local.fio_job_names[count.index]], "rwmixread", 50),
    SIZE          = "42k"
  })
  tags = {
    Name = "s3fs-${local.fio_job_names[count.index]}-42k"
  }
}

#resource "aws_instance" "s3fs_1m" {
#  count                  = length(local.fio_job_names)
#  ami                    = var.ubuntu
#  instance_type          = var.instance_type
#  iam_instance_profile   = aws_iam_instance_profile.fuse_benchmark_iam_profile.name
#  vpc_security_group_ids = [aws_security_group.fuse_benchmark_allow_all.id]
#  user_data              = templatefile("${path.module}/configs/s3fs.sh", {
#    AWS_REGION    = data.aws_region.current.name,
#    MOUNT         = "/tmp/s3",
#    BUCKET        = aws_s3_bucket.s3fs_buckets[count.index].bucket,
#    FIO_CONFIG    = "/home/ubuntu/s3fs.fio",
#    IAM_ROLE      = aws_iam_role.fuse_benchmark_iam_role.name,
#    REPORT_NAME   = "s3fs-${local.fio_job_names[count.index]}-1m.report",
#    RESULT        = "/home/ubuntu/s3fs-${local.fio_job_names[count.index]}-1m.report",
#    REPORT_BUCKET = aws_s3_bucket.s3fs_results.bucket,
#    JOBNAME       = local.fio_job_names[count.index],
#    NUMJOBS       = local.fio_jobs_json[local.fio_job_names[count.index]]["numjobs"],
#    FIORW         = local.fio_jobs_json[local.fio_job_names[count.index]]["rw"],
#    RWMIXWRITE    = lookup(local.fio_jobs_json[local.fio_job_names[count.index]], "rwmixwrite", 50),
#    RWMIXREAD     = lookup(local.fio_jobs_json[local.fio_job_names[count.index]], "rwmixread", 50),
#    SIZE          = "1m"
#  })
#  tags = {
#    Name = "s3fs-${local.fio_job_names[count.index]}-1m"
#  }
#}
#
#resource "aws_instance" "s3fs_63m" {
#  count                  = length(local.fio_job_names)
#  ami                    = var.ubuntu
#  instance_type          = var.instance_type
#  iam_instance_profile   = aws_iam_instance_profile.fuse_benchmark_iam_profile.name
#  vpc_security_group_ids = [aws_security_group.fuse_benchmark_allow_all.id]
#  user_data              = templatefile("${path.module}/configs/s3fs.sh", {
#    AWS_REGION    = data.aws_region.current.name,
#    MOUNT         = "/tmp/s3",
#    BUCKET        = aws_s3_bucket.s3fs_buckets[count.index].bucket,
#    FIO_CONFIG    = "/home/ubuntu/s3fs.fio",
#    IAM_ROLE      = aws_iam_role.fuse_benchmark_iam_role.name,
#    REPORT_NAME   = "s3fs-${local.fio_job_names[count.index]}-63m.report",
#    RESULT        = "/home/ubuntu/s3fs-${local.fio_job_names[count.index]}-63m.report",
#    REPORT_BUCKET = aws_s3_bucket.s3fs_results.bucket,
#    JOBNAME       = local.fio_job_names[count.index],
#    NUMJOBS       = local.fio_jobs_json[local.fio_job_names[count.index]]["numjobs"],
#    FIORW         = local.fio_jobs_json[local.fio_job_names[count.index]]["rw"],
#    RWMIXWRITE    = lookup(local.fio_jobs_json[local.fio_job_names[count.index]], "rwmixwrite", 50),
#    RWMIXREAD     = lookup(local.fio_jobs_json[local.fio_job_names[count.index]], "rwmixread", 50),
#    SIZE          = "63m"
#  })
#  tags = {
#    Name = "s3fs-${local.fio_job_names[count.index]}-63m"
#  }
#}
#
#resource "aws_instance" "s3fs_1g" {
#  count                  = length(local.fio_job_names)
#  ami                    = var.ubuntu
#  instance_type          = var.instance_type
#  iam_instance_profile   = aws_iam_instance_profile.fuse_benchmark_iam_profile.name
#  vpc_security_group_ids = [aws_security_group.fuse_benchmark_allow_all.id]
#  user_data              = templatefile("${path.module}/configs/s3fs.sh", {
#    AWS_REGION    = data.aws_region.current.name,
#    MOUNT         = "/tmp/s3",
#    BUCKET        = aws_s3_bucket.s3fs_buckets[count.index].bucket,
#    FIO_CONFIG    = "/home/ubuntu/s3fs.fio",
#    IAM_ROLE      = aws_iam_role.fuse_benchmark_iam_role.name,
#    REPORT_NAME   = "s3fs-${local.fio_job_names[count.index]}-1g.report",
#    RESULT        = "/home/ubuntu/s3fs-${local.fio_job_names[count.index]}-1g.report",
#    REPORT_BUCKET = aws_s3_bucket.s3fs_results.bucket,
#    JOBNAME       = local.fio_job_names[count.index],
#    NUMJOBS       = local.fio_jobs_json[local.fio_job_names[count.index]]["numjobs"],
#    FIORW         = local.fio_jobs_json[local.fio_job_names[count.index]]["rw"],
#    RWMIXWRITE    = lookup(local.fio_jobs_json[local.fio_job_names[count.index]], "rwmixwrite", 50),
#    RWMIXREAD     = lookup(local.fio_jobs_json[local.fio_job_names[count.index]], "rwmixread", 50),
#    SIZE          = "1g"
#  })
#  tags = {
#    Name = "s3fs-${local.fio_job_names[count.index]}-1g"
#  }
#}
#
#resource "aws_instance" "s3fs_4g" {
#  count                  = length(local.fio_job_names)
#  ami                    = var.ubuntu
#  instance_type          = var.instance_type
#  iam_instance_profile   = aws_iam_instance_profile.fuse_benchmark_iam_profile.name
#  vpc_security_group_ids = [aws_security_group.fuse_benchmark_allow_all.id]
#  user_data              = templatefile("${path.module}/configs/s3fs.sh", {
#    AWS_REGION    = data.aws_region.current.name,
#    MOUNT         = "/tmp/s3",
#    BUCKET        = aws_s3_bucket.s3fs_buckets[count.index].bucket,
#    FIO_CONFIG    = "/home/ubuntu/s3fs.fio",
#    IAM_ROLE      = aws_iam_role.fuse_benchmark_iam_role.name,
#    REPORT_NAME   = "s3fs-${local.fio_job_names[count.index]}-4g.report",
#    RESULT        = "/home/ubuntu/s3fs-${local.fio_job_names[count.index]}-4g.report",
#    REPORT_BUCKET = aws_s3_bucket.s3fs_results.bucket,
#    JOBNAME       = local.fio_job_names[count.index],
#    NUMJOBS       = local.fio_jobs_json[local.fio_job_names[count.index]]["numjobs"],
#    FIORW         = local.fio_jobs_json[local.fio_job_names[count.index]]["rw"],
#    RWMIXWRITE    = lookup(local.fio_jobs_json[local.fio_job_names[count.index]], "rwmixwrite", 50),
#    RWMIXREAD     = lookup(local.fio_jobs_json[local.fio_job_names[count.index]], "rwmixread", 50),
#    SIZE          = "4g"
#  })
#  tags = {
#    Name = "s3fs-${local.fio_job_names[count.index]}-4g"
#  }
#}
#
#resource "aws_instance" "s3fs_20_5g" {
#  count                  = length(local.fio_job_names)
#  ami                    = var.ubuntu
#  instance_type          = var.instance_type
#  iam_instance_profile   = aws_iam_instance_profile.fuse_benchmark_iam_profile.name
#  vpc_security_group_ids = [aws_security_group.fuse_benchmark_allow_all.id]
#  user_data              = templatefile("${path.module}/configs/s3fs.sh", {
#    AWS_REGION    = data.aws_region.current.name,
#    MOUNT         = "/tmp/s3",
#    BUCKET        = aws_s3_bucket.s3fs_buckets[count.index].bucket,
#    FIO_CONFIG    = "/home/ubuntu/s3fs.fio",
#    IAM_ROLE      = aws_iam_role.fuse_benchmark_iam_role.name,
#    REPORT_NAME   = "s3fs-${local.fio_job_names[count.index]}-20_5g.report",
#    RESULT        = "/home/ubuntu/s3fs-${local.fio_job_names[count.index]}-20_5g.report",
#    REPORT_BUCKET = aws_s3_bucket.s3fs_results.bucket,
#    JOBNAME       = local.fio_job_names[count.index],
#    NUMJOBS       = local.fio_jobs_json[local.fio_job_names[count.index]]["numjobs"],
#    FIORW         = local.fio_jobs_json[local.fio_job_names[count.index]]["rw"],
#    RWMIXWRITE    = lookup(local.fio_jobs_json[local.fio_job_names[count.index]], "rwmixwrite", 50),
#    RWMIXREAD     = lookup(local.fio_jobs_json[local.fio_job_names[count.index]], "rwmixread", 50),
#    SIZE          = "20.5g"
#  })
#  tags = {
#    Name = "s3fs-${local.fio_job_names[count.index]}-20_5g"
#  }
#}

output "ec2_s3fs_benchmark_public_ip" {
  value = local.instances_public_ips
}

output "s3fs_benchmark_buckets" {
  value = local.s3_benchmarks_buckets
}

output "s3_benchmark_reports_bucket" {
  value = aws_s3_bucket.reports.bucket
}

output "formatted_timestamp" {
  value = local.formatted_timestamp
}