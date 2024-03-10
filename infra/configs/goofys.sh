#!/bin/bash

touch /home/ubuntu/0.txt

sudo su

apt update -y
apt install fio -y
apt install awscli -y

mkdir -p /home/filebase/go/src/github.com/kahing
cd /home/filebase/go/src/github.com/kahing/
touch /home/ubuntu/00.txt
git clone https://github.com/kahing/goofys.git
export GOPATH=/home/filebase/go
touch /home/ubuntu/000.txt
export GOOFYS_HOME=/home/filebase/go/src/github.com/kahing/goofys/
cd /home/filebase/go/src/github.com/kahing/goofys
touch /home/ubuntu/000.txt
git submodule init
git submodule update
touch /home/ubuntu/0000.txt
make build
PATH=$PATH:/home/filebase/go/bin; export PATH
touch /home/ubuntu/00000.txt
mkdir /tmp/goofys

touch /home/ubuntu/1.txt

$GOPATH/bin/goofys ${BUCKET} ${MOUNT}

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