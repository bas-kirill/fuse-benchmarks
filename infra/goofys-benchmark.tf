resource "aws_s3_bucket" "goofys_buckets" {
  count  = length(local.fio_job_names)
  bucket = replace("goofys-${local.fio_job_names[count.index]}-${local.formatted_timestamp}", "-", "")
}

#resource "aws_instance" "goofys_42k" {
#  count                  = length(local.fio_job_names)
#  ami                    = var.ubuntu
#  instance_type          = var.instance_type
#  iam_instance_profile   = aws_iam_instance_profile.fuse_benchmark_iam_profile.name
#  vpc_security_group_ids = [aws_security_group.fuse_benchmark_allow_all.id]
#  user_data              = templatefile("${path.module}/configs/goofys.sh", {
#    AWS_REGION    = data.aws_region.current.name,
#    MOUNT         = "/tmp/goofys",
#    BUCKET        = aws_s3_bucket.goofys_buckets[count.index].bucket,
#    FIO_CONFIG    = "/home/ubuntu/goofys.fio",
#    IAM_ROLE      = aws_iam_role.fuse_benchmark_iam_role.name,
#    REPORT_NAME   = "goofys-${local.fio_job_names[count.index]}-42k.report",
#    RESULT        = "/home/ubuntu/goofys-${local.fio_job_names[count.index]}-42k.report",
#    REPORT_BUCKET = aws_s3_bucket.reports.bucket,
#    JOBNAME       = local.fio_job_names[count.index],
#    NUMJOBS       = local.fio_jobs_json[local.fio_job_names[count.index]]["numjobs"],
#    FIORW         = local.fio_jobs_json[local.fio_job_names[count.index]]["rw"],
#    RWMIXWRITE    = lookup(local.fio_jobs_json[local.fio_job_names[count.index]], "rwmixwrite", 50),
#    RWMIXREAD     = lookup(local.fio_jobs_json[local.fio_job_names[count.index]], "rwmixread", 50),
#    SIZE          = "42k"
#  })
#  tags = {
#    Name = "goofys-${local.fio_job_names[count.index]}-42k"
#  }
#}