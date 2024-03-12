#!/usr/bin/env bash
set -ex

touch /home/ubuntu/0.txt

apt update -y
apt install fio -y
apt install awscli -y
wget -P /home/ubuntu https://s3.amazonaws.com/mountpoint-s3-release/latest/arm64/mount-s3.deb
apt-get install /home/ubuntu/mount-s3.deb -y

touch /home/ubuntu/1.txt

mkdir ${MOUNT}

touch /home/ubuntu/2.txt

mount-s3 ${BUCKET} ${MOUNT} --allow-delete

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
