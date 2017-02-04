#! /bin/bash

while read line; do
    arr=(${line})
    n=${#arr[@]}
    for i in $(seq 1 $((n-1))); do
        j=$((i-1))
        key=${arr[0]}
        val=${arr[${i}]}
        eval ${key}[${j}]=\"${val}\"
    done
done < ${1}

