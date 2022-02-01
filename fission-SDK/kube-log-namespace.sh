#!/bin/bash

kube_namespace=$1
log_cmd="kubectl -n $kube_namespace logs --all-containers --since=1s -f"

log_file="function-logs.log"

for i in $(kubectl -n $kube_namespace get pods -o name); do
    $log_cmd $i | ts "$kube_namespace $i" >> $log_file &
done

tail -f $log_file