#!/bin/sh

if [ ! $1 -o "$1" = "help" ]; then
    echo "help"
    echo "sh restart.sh node"
    exit 0;
else
	node=$1

	status=`sh ./tools/shell/status.sh $node`
	if [ "$status" = "start" ]; then
		sh stop.sh $node
        sleep 5
	fi

	sh start.sh $node
fi
