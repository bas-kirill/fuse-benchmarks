data "aws_region" "current" {}

locals {
  jobs = {
    for job in flatten([
      for job in var.fio_jobs : [
        for pair in setproduct([job], var.file_sizes) : {
          job_name  = pair[0].job_name
          num_jobs  = pair[0].num_jobs
          rw        = pair[0].rw
          file_size = pair[1]
        }
      ]
    ]) : "${var.fs}-${job.job_name}-${job.file_size}" => job
  }
}

resource "aws_iam_role" "fuse_benchmark_iam_role" {
  name               = "${var.fs}-fuse_benchmark"
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
  depends_on = [aws_iam_role.fuse_benchmark_iam_role]
}

resource "aws_iam_instance_profile" "fuse_benchmark_iam_profile" {
  name       = "${var.fs}-fuse_benchmark"
  role       = aws_iam_role.fuse_benchmark_iam_role.name
  depends_on = [aws_iam_role_policy_attachment.fuse_benchmark_policy_attachment]
}

resource "aws_security_group" "fuse_benchmark_allow_all" {
  name        = "${var.fs}-allow_all_traffic"
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

resource "aws_s3_bucket" "job_bucket" {
  for_each      = local.jobs
  bucket = each.key
  force_destroy = true
}

resource "aws_s3_bucket" "report" {
  bucket        = "${var.fs}-fuse-benchmarks"
  force_destroy = true
}

resource "aws_instance" "server" {
  for_each                    = local.jobs
  ami                         = var.ubuntu
  instance_type               = var.instance_type
  iam_instance_profile        = aws_iam_instance_profile.fuse_benchmark_iam_profile.name
  vpc_security_group_ids      = [aws_security_group.fuse_benchmark_allow_all.id]
  user_data_replace_on_change = true
  user_data                   = templatefile(var.user_data_template_path, {
    AWS_REGION    = data.aws_region.current.name,
    MOUNT         = var.mount,
    BUCKET        = each.key,
    FIO_CONFIG    = var.fio_config,
    IAM_ROLE      = aws_iam_role.fuse_benchmark_iam_role.name,
    REPORT_NAME   = "${each.key}.txt",
    RESULT        = "/home/ubuntu/${each.key}.txt",
    REPORT_BUCKET = aws_s3_bucket.report.bucket,
    JOBNAME       = each.value.job_name,
    NUMJOBS       = each.value.num_jobs,
    FIORW         = each.value.rw,
    RWMIXWRITE    = can(each.value.rw_mix_write) ? each.value.rw_mix_write : "50",
    RWMIXREAD     = can(each.value.rw_mix_read) ? each.value.rw_mix_read : "50",
    SIZE          = each.value.file_size,
  })
  tags = {
    Name = each.key
  }

  depends_on = [
    aws_iam_instance_profile.fuse_benchmark_iam_profile,
    aws_security_group.fuse_benchmark_allow_all,
    aws_s3_bucket.job_bucket,
    aws_s3_bucket.report,
  ]
}
