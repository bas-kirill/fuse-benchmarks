#!/bin/sh
set -e
currentDir=$(cd -P -- "$(dirname -- "$0")" && pwd -P)
rootDir="$currentDir/../../"

(cd $rootDir && exec terraform fmt -list=true -recursive)
(cd $rootDir && exec terraform validate)
