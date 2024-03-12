#!/usr/bin/env bash
set -ex

apt update -y
apt install fio -y
apt install awscli -y

apt install golang-go -y  # install "go" cli command
git clone https://github.com/yandex-cloud/geesefs /home/ubuntu/geesefs
cd /home/ubuntu/geesefs

export HOME=/root
export GOPATH=$HOME/go
export GO111MODULE=on
export GOCACHE=/root/.cache/go-build
go build ./
cd /home/ubuntu

mkdir ${MOUNT}

/home/ubuntu/geesefs/geesefs \
  --no-checksum \
  --memory-limit 4000 \
  --max-flushers 32 \
  --max-parallel-parts 32 \
  --part-sizes 25 \
  --file-mode=0666 \
  --dir-mode=0777 \
  --endpoint https://s3.amazonaws.com ${BUCKET} ${MOUNT}

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
