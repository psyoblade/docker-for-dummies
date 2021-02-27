#!/bin/bash

function run_application() {
    app_name=$1
    sleep_secs=$2
    echo "$app_name will be executed for $sleep_secs seconds"
    for x in $(seq 1 $sleep_secs); do
        echo "[$x] $app_name is running..."
        sleep 1
    done
    echo "$app_name completed"
}

if [ "$1" == "sqoop" ]; then
    "run sqoop batch task"
    run_application $1 10
elif [ "$1" == "fluentd" ]; then
    "run fluentd daemon process"
    run_application $1 3600
else
    echo "./aiffel.sh [sqoop|fluentd]"
fi
