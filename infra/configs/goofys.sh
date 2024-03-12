#!/usr/bin/env bash
set -ex

touch /home/ubuntu/0.txt

apt update -y
apt install fio -y
apt install awscli -y
apt install make -y
apt install golang-go -y  # install "go" cli command

touch /home/ubuntu/00.txt

wget -P /home/ubuntu https://github.com/kahing/goofys/releases/latest/download/goofys
chmod +x /home/ubuntu/goofys
mkdir ${MOUNT}

touch /home/ubuntu/1.txt

/home/ubuntu/goofys ${BUCKET} ${MOUNT}

touch /home/ubuntu/2.txt

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

touch /home/ubuntu/3.txt

fio ${FIO_CONFIG} > ${RESULT}

touch /home/ubuntu/4.txt

aws s3 cp ${RESULT} s3://${REPORT_BUCKET}/${REPORT_NAME}

touch /home/ubuntu/5.txt

aws s3 rm s3://${BUCKET} --recursive
instance_id=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
aws ec2 terminate-instances --instance-ids $instance_id --region ${AWS_REGION}

touch /home/ubuntu/6.txt