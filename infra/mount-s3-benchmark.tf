resource "aws_s3_bucket" "mounts3_buckets" {
  count  = length(local.fio_job_names)
  bucket = replace("mounts3-${local.fio_job_names[count.index]}-${local.formatted_timestamp}", "-", "")
}

#resource "aws_instance" "mounts3_42k" {
#  count                  = length(local.fio_job_names)
#  ami                    = var.ubuntu
#  instance_type          = var.instance_type
#  iam_instance_profile   = aws_iam_instance_profile.fuse_benchmark_iam_profile.name
#  vpc_security_group_ids = [aws_security_group.fuse_benchmark_allow_all.id]
#  user_data              = templatefile("${path.module}/configs/mount-s3.sh", {
#    AWS_REGION    = data.aws_region.current.name,
#    MOUNT         = "/tmp/mounts3",
#    BUCKET        = aws_s3_bucket.goofys_buckets[count.index].bucket,
#    FIO_CONFIG    = "/home/ubuntu/mounts3.fio",
#    IAM_ROLE      = aws_iam_role.fuse_benchmark_iam_role.name,
#    REPORT_NAME   = "mounts3-${local.fio_job_names[count.index]}-42k.txt",
#    RESULT        = "/home/ubuntu/mounts3-${local.fio_job_names[count.index]}-42k.txt",
#    REPORT_BUCKET = aws_s3_bucket.reports.bucket,
#    JOBNAME       = local.fio_job_names[count.index],
#    NUMJOBS       = local.fio_jobs_json[local.fio_job_names[count.index]]["numjobs"],
#    FIORW         = local.fio_jobs_json[local.fio_job_names[count.index]]["rw"],
#    RWMIXWRITE    = lookup(local.fio_jobs_json[local.fio_job_names[count.index]], "rwmixwrite", 50),
#    RWMIXREAD     = lookup(local.fio_jobs_json[local.fio_job_names[count.index]], "rwmixread", 50),
#    SIZE          = "42k"
#  })
#  tags = {
#    Name = "mounts3-${local.fio_job_names[count.index]}-42k"
#  }
#}
