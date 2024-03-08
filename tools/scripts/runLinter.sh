#!/bin/sh
set -e
terraform fmt -list=true -recursive
terraform validate
