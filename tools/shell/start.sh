#!/bin/sh

if [ ! $1 -o "$1" = "help" ]; then
    echo "help"
    echo "run.sh start node"
else
    node=$1

    configfile=./etc/server/$node.conf
    if [ ! -f $configfile ]; then
        echo "config file not exist: $configfile"
        exit 0;
    fi

    status=`sh ./tools/shell/status.sh $node`
    if [ "$status" = "start" ]; then
        echo "$node aready start"
        exit 0;
    elif [ "$status" = "killed" ]; then
        pidfile=./log/$node/skynet.pid
        if [ -f $pidfile ]; then
            rm $pidfile
        fi
    fi

    export DAEMON=false
    if [ $2 -a $2 = "D" ]; then
        DAEMON=true
    fi

    mkdir -p ./log/$node
    chmod +x ./skynet/skynet
    ./skynet/skynet $configfile
fi