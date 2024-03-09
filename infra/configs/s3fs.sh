#!/bin/bash
set -e
sudo su

touch /home/ubuntu/0.txt

apt update -y
apt install s3fs -y
apt install fio -y
apt install awscli -y

touch /home/ubuntu/1.txt

mkdir ${MOUNT}

touch /home/ubuntu/2.txt

s3fs ${BUCKET} ${MOUNT} -o parallel_count=400,ensure_diskfree=1024,del_cache,use_cache=/tmp/,iam_role=${IAM_ROLE}

touch /home/ubuntu/3.txt

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

touch /home/ubuntu/4.txt

fio ${FIO_CONFIG} > ${RESULT}

touch /home/ubuntu/5.txt

aws s3 cp ${RESULT} s3://${REPORT_BUCKET}/${REPORT_NAME}

touch /home/ubuntu/6.txt

aws s3 rm s3://${BUCKET} --recursive
instance_id=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
aws ec2 terminate-instances --instance-ids $instance_id --region ${AWS_REGION}

touch /home/ubuntu/7.txt
