#!/bin/sh

if [ ! $1 -o "$1" = "help" ]; then
    echo "help"
    echo "sh kill.sh node"
	exit 0;
else
	node=$1

	status=`sh ./tools/shell/status.sh $node`
	if [ "$status" != "start" ]; then
		echo "aready stop"
		exit 0;
	fi

	ps -ef | grep skynet | grep $node | awk '{print $2}' | xargs kill -9
	echo "kill $node ok"
fi