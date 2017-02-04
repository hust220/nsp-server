#! /bin/bash

n=0
while [ $# != 0 ]; do
    if [ ${1:0:1} == '-' ]; then break;
    else global[n]=${1}; n=$((n+1)); fi
    shift
done

while [ $# != 0 ]; do
    if [ ${1:0:1} == '-' ]; then par_name=${1:1}; eval ${par_name}=yes; n=0;
    else eval ${par_name}[${n}]=\"${1}\"; n=$((n+1)); fi
    shift
done

