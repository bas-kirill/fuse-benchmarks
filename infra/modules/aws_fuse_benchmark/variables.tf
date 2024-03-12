variable "instance_type" {
  type    = string
  default = "t3.micro"
  #  "c6g.4xlarge"
}

variable "ubuntu" {
  type    = string
  default = "ami-00381a880aa48c6c6"
  # "ami-08a7297c0f05d943d"
  #
  #
}

variable "user_data_template_path" {
  default = "../../configs/s3fs.sh"
}

variable "fs" {
  default = "s3fs"
}

variable "mount" {
  default = "/tmp/s3"
}

variable "fio_config" {
  default = "/home/ubuntu/config.fio"
}


variable "fio_jobs" {
  default = [
    {
      job_name : "1-job-sequential-read",
      num_jobs : "1",
      rw : "read"
    },
    {
      job_name : "1-job-sequential-write",
      num_jobs : "1",
      rw : "write"
    },
    {
      job_name : "1-job-70-read",
      num_jobs : "1",
      rw : "rw",
      rw_mix_write : "30",
      rw_mix_read : "70"
    },
    {
      job_name : "1-job-30-write",
      num_jobs : "1",
      rw : "rw",
      rw_mix_write : "30",
      rw_mix_read : "70"
    },
    {
      job_name : "1-job-random-read",
      num_jobs : "1",
      rw : "randread"
    },
    {
      job_name : "1-job-random-write",
      num_jobs : "1",
      rw : "randwrite"
    },
    {
      job_name : "16-job-sequential-read",
      num_jobs : "16",
      rw : "read"
    },
    {
      job_name : "16-job-sequential-write",
      num_jobs : "16",
      rw : "write"
    },
    {
      job_name : "16-job-70-read",
      num_jobs : "16",
      rw : "rw",
      rw_mix_write : "30",
      rw_mix_read : "70"
    },
    {
      job_name : "16-job-30-write",
      num_jobs : "16",
      rw : "rw",
      rw_mix_write : "30",
      rw_mix_read : "70"
    },
    {
      job_name : "16-job-random-read",
      num_jobs : "16",
      rw : "randread"
    },
    {
      job_name : "16-job-random-write",
      num_jobs : "16",
      rw : "randwrite"
    }
  ]
}

variable "file_sizes" {
  default = ["42k"] # , "1m", "63m", "1g", "4g", "20.5g"]   # According to ML dataset distribution
}
