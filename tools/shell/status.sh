#!/bin/sh

if [ ! $1 -o "$1" = "help" ]; then
    echo "help"
    echo "sh status.sh node"
    exit 0;
else
    node=$1

    pid=`ps -ef | grep skynet | grep $1 | awk '{print $2}'`

    if ps -p $pid >/dev/null 2>&1; then
        echo "start"
    else
        pidfile=./log/$node/skynet.pid
        if ! [ -f $pidfile ]; then
            echo "stop"
        else
            echo "killed" # unsafe stop
        fi
        exit 0;
    fi
fi