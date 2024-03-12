#!/usr/bin/env bash
set -ex

apt update -y
apt install fio -y
apt install awscli -y
curl https://rclone.org/install.sh | sudo bash

mkdir ${MOUNT}

mkdir -p ~/.config/rclone/

cat <<EOF > ~/.config/rclone/rclone.conf
[myS3Bucket]
type = s3
provider = AWS
env_auth = true
region = us-east-1
acl = private
EOF

rclone mount myS3Bucket:/${BUCKET} ${MOUNT} --vfs-cache-mode full --daemon

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
