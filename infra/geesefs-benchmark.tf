resource "aws_s3_bucket" "geesefs_buckets" {
  count  = length(local.fio_job_names)
  bucket = replace("geesefs-${local.fio_job_names[count.index]}-${local.formatted_timestamp}", "-", "")
}

resource "aws_instance" "geesefs_42k" {
  count                       = length(local.fio_job_names)
  ami                         = var.ubuntu
  instance_type               = var.instance_type
  iam_instance_profile        = aws_iam_instance_profile.fuse_benchmark_iam_profile.name
  vpc_security_group_ids      = [aws_security_group.fuse_benchmark_allow_all.id]
  user_data_replace_on_change = true
  user_data                   = templatefile("${path.module}/configs/geesefs.sh", {
    AWS_REGION    = data.aws_region.current.name,
    MOUNT         = "/tmp/geesefs",
    BUCKET        = aws_s3_bucket.goofys_buckets[count.index].bucket,
    FIO_CONFIG    = "/home/ubuntu/geesefs.fio",
    IAM_ROLE      = aws_iam_role.fuse_benchmark_iam_role.name,
    REPORT_NAME   = "geesefs-${local.fio_job_names[count.index]}-42k.txt",
    RESULT        = "/home/ubuntu/geesefs-${local.fio_job_names[count.index]}-42k.txt",
    REPORT_BUCKET = aws_s3_bucket.reports.bucket,
    JOBNAME       = local.fio_job_names[count.index],
    NUMJOBS       = local.fio_jobs_json[local.fio_job_names[count.index]]["numjobs"],
    FIORW         = local.fio_jobs_json[local.fio_job_names[count.index]]["rw"],
    RWMIXWRITE    = lookup(local.fio_jobs_json[local.fio_job_names[count.index]], "rwmixwrite", 50),
    RWMIXREAD     = lookup(local.fio_jobs_json[local.fio_job_names[count.index]], "rwmixread", 50),
    SIZE          = "42k"
  })
  tags = {
    Name = "geesefs-${local.fio_job_names[count.index]}-42k"
  }
}

resource "aws_instance" "geesefs_1m" {
  count                       = length(local.fio_job_names)
  ami                         = var.ubuntu
  instance_type               = var.instance_type
  iam_instance_profile        = aws_iam_instance_profile.fuse_benchmark_iam_profile.name
  vpc_security_group_ids      = [aws_security_group.fuse_benchmark_allow_all.id]
  user_data_replace_on_change = true
  user_data                   = templatefile("${path.module}/configs/geesefs.sh", {
    AWS_REGION    = data.aws_region.current.name,
    MOUNT         = "/tmp/geesefs",
    BUCKET        = aws_s3_bucket.goofys_buckets[count.index].bucket,
    FIO_CONFIG    = "/home/ubuntu/geesefs.fio",
    IAM_ROLE      = aws_iam_role.fuse_benchmark_iam_role.name,
    REPORT_NAME   = "geesefs-${local.fio_job_names[count.index]}-1m.txt",
    RESULT        = "/home/ubuntu/geesefs-${local.fio_job_names[count.index]}-1m.txt",
    REPORT_BUCKET = aws_s3_bucket.reports.bucket,
    JOBNAME       = local.fio_job_names[count.index],
    NUMJOBS       = local.fio_jobs_json[local.fio_job_names[count.index]]["numjobs"],
    FIORW         = local.fio_jobs_json[local.fio_job_names[count.index]]["rw"],
    RWMIXWRITE    = lookup(local.fio_jobs_json[local.fio_job_names[count.index]], "rwmixwrite", 50),
    RWMIXREAD     = lookup(local.fio_jobs_json[local.fio_job_names[count.index]], "rwmixread", 50),
    SIZE          = "1m"
  })
  tags = {
    Name = "geesefs-${local.fio_job_names[count.index]}-1m"
  }
}

resource "aws_instance" "geesefs_63m" {
  count                       = length(local.fio_job_names)
  ami                         = var.ubuntu
  instance_type               = var.instance_type
  iam_instance_profile        = aws_iam_instance_profile.fuse_benchmark_iam_profile.name
  vpc_security_group_ids      = [aws_security_group.fuse_benchmark_allow_all.id]
  user_data_replace_on_change = true
  user_data                   = templatefile("${path.module}/configs/geesefs.sh", {
    AWS_REGION    = data.aws_region.current.name,
    MOUNT         = "/tmp/geesefs",
    BUCKET        = aws_s3_bucket.goofys_buckets[count.index].bucket,
    FIO_CONFIG    = "/home/ubuntu/geesefs.fio",
    IAM_ROLE      = aws_iam_role.fuse_benchmark_iam_role.name,
    REPORT_NAME   = "geesefs-${local.fio_job_names[count.index]}-63m.txt",
    RESULT        = "/home/ubuntu/geesefs-${local.fio_job_names[count.index]}-63m.txt",
    REPORT_BUCKET = aws_s3_bucket.reports.bucket,
    JOBNAME       = local.fio_job_names[count.index],
    NUMJOBS       = local.fio_jobs_json[local.fio_job_names[count.index]]["numjobs"],
    FIORW         = local.fio_jobs_json[local.fio_job_names[count.index]]["rw"],
    RWMIXWRITE    = lookup(local.fio_jobs_json[local.fio_job_names[count.index]], "rwmixwrite", 50),
    RWMIXREAD     = lookup(local.fio_jobs_json[local.fio_job_names[count.index]], "rwmixread", 50),
    SIZE          = "63m"
  })
  tags = {
    Name = "geesefs-${local.fio_job_names[count.index]}-63m"
  }
}

resource "aws_instance" "geesefs_1g" {
  count                  = length(local.fio_job_names)
  ami                    = var.ubuntu
  instance_type          = var.instance_type
  iam_instance_profile   = aws_iam_instance_profile.fuse_benchmark_iam_profile.name
  vpc_security_group_ids = [aws_security_group.fuse_benchmark_allow_all.id]
  user_data_replace_on_change = true
  user_data              = templatefile("${path.module}/configs/geesefs.sh", {
    AWS_REGION    = data.aws_region.current.name,
    MOUNT         = "/tmp/geesefs",
    BUCKET        = aws_s3_bucket.goofys_buckets[count.index].bucket,
    FIO_CONFIG    = "/home/ubuntu/geesefs.fio",
    IAM_ROLE      = aws_iam_role.fuse_benchmark_iam_role.name,
    REPORT_NAME   = "geesefs-${local.fio_job_names[count.index]}-1g.txt",
    RESULT        = "/home/ubuntu/geesefs-${local.fio_job_names[count.index]}-1g.txt",
    REPORT_BUCKET = aws_s3_bucket.reports.bucket,
    JOBNAME       = local.fio_job_names[count.index],
    NUMJOBS       = local.fio_jobs_json[local.fio_job_names[count.index]]["numjobs"],
    FIORW         = local.fio_jobs_json[local.fio_job_names[count.index]]["rw"],
    RWMIXWRITE    = lookup(local.fio_jobs_json[local.fio_job_names[count.index]], "rwmixwrite", 50),
    RWMIXREAD     = lookup(local.fio_jobs_json[local.fio_job_names[count.index]], "rwmixread", 50),
    SIZE          = "1g"
  })
  tags = {
    Name = "geesefs-${local.fio_job_names[count.index]}-1g"
  }
}

resource "aws_instance" "geesefs_4g" {
  count                  = length(local.fio_job_names)
  ami                    = var.ubuntu
  instance_type          = var.instance_type
  iam_instance_profile   = aws_iam_instance_profile.fuse_benchmark_iam_profile.name
  vpc_security_group_ids = [aws_security_group.fuse_benchmark_allow_all.id]
  user_data_replace_on_change = true
  user_data              = templatefile("${path.module}/configs/geesefs.sh", {
    AWS_REGION    = data.aws_region.current.name,
    MOUNT         = "/tmp/geesefs",
    BUCKET        = aws_s3_bucket.goofys_buckets[count.index].bucket,
    FIO_CONFIG    = "/home/ubuntu/geesefs.fio",
    IAM_ROLE      = aws_iam_role.fuse_benchmark_iam_role.name,
    REPORT_NAME   = "geesefs-${local.fio_job_names[count.index]}-4g.txt",
    RESULT        = "/home/ubuntu/geesefs-${local.fio_job_names[count.index]}-4g.txt",
    REPORT_BUCKET = aws_s3_bucket.reports.bucket,
    JOBNAME       = local.fio_job_names[count.index],
    NUMJOBS       = local.fio_jobs_json[local.fio_job_names[count.index]]["numjobs"],
    FIORW         = local.fio_jobs_json[local.fio_job_names[count.index]]["rw"],
    RWMIXWRITE    = lookup(local.fio_jobs_json[local.fio_job_names[count.index]], "rwmixwrite", 50),
    RWMIXREAD     = lookup(local.fio_jobs_json[local.fio_job_names[count.index]], "rwmixread", 50),
    SIZE          = "4g"
  })
  tags = {
    Name = "geesefs-${local.fio_job_names[count.index]}-42k"
  }
}

#resource "aws_instance" "geesefs_20_5g" {
#  count                  = length(local.fio_job_names)
#  ami                    = var.ubuntu
#  instance_type          = var.instance_type
#  iam_instance_profile   = aws_iam_instance_profile.fuse_benchmark_iam_profile.name
#  vpc_security_group_ids = [aws_security_group.fuse_benchmark_allow_all.id]
#  user_data_replace_on_change = true
#  user_data              = templatefile("${path.module}/configs/geesefs.sh", {
#    AWS_REGION    = data.aws_region.current.name,
#    MOUNT         = "/tmp/geesefs",
#    BUCKET        = aws_s3_bucket.goofys_buckets[count.index].bucket,
#    FIO_CONFIG    = "/home/ubuntu/geesefs.fio",
#    IAM_ROLE      = aws_iam_role.fuse_benchmark_iam_role.name,
#    REPORT_NAME   = "geesefs-${local.fio_job_names[count.index]}-20-5g.txt",
#    RESULT        = "/home/ubuntu/geesefs-${local.fio_job_names[count.index]}-20-5g.txt",
#    REPORT_BUCKET = aws_s3_bucket.reports.bucket,
#    JOBNAME       = local.fio_job_names[count.index],
#    NUMJOBS       = local.fio_jobs_json[local.fio_job_names[count.index]]["numjobs"],
#    FIORW         = local.fio_jobs_json[local.fio_job_names[count.index]]["rw"],
#    RWMIXWRITE    = lookup(local.fio_jobs_json[local.fio_job_names[count.index]], "rwmixwrite", 50),
#    RWMIXREAD     = lookup(local.fio_jobs_json[local.fio_job_names[count.index]], "rwmixread", 50),
#    SIZE          = "20.5g"
#  })
#  tags = {
#    Name = "geesefs-${local.fio_job_names[count.index]}-20-5g"
#  }
#}
