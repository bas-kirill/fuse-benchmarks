#!/bin/bash
set -e
sudo su

apt update -y
apt install s3fs -y
apt install fio -y
apt install awscli -y

mkdir ${MOUNT}

s3fs ${BUCKET} ${MOUNT} -o parallel_count=400,ensure_diskfree=1024,del_cache,use_cache=/tmp/,iam_role=${IAM_ROLE}

cat <<EOF > ${FIO_CONFIG}
[global]
direct=1
ioengine=libaio
iodepth=16
bs=512

[${JOBNAME}]
name=${JOBNAME}
numjobs=${NUMJOBS}
directory=${MOUNT}
rw=${FIORW}
rwmixwrite=${RWMIXWRITE}
rwmixread=${RWMIXREAD}
size=${SIZE}
EOF

fio ${FIO_CONFIG} > ${RESULT}

aws s3 cp ${RESULT} s3://${REPORT_BUCKET}/${REPORT_NAME}

aws s3 rm s3://${BUCKET} --recursive
instance_id=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
aws ec2 terminate-instances --instance-ids $instance_id --region ${AWS_REGION}
