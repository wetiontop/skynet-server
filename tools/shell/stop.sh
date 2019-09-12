#! /bin/sh

if [ ! $1 -o "$1" = "help" ]; then
    echo "help"
    echo "sh stop.sh all"
    echo "sh stop.sh node"
	exit 0;
else
	node=$1

	status=`sh ./tools/shell/status.sh $node`
	if [ "$status" != "start" ]; then
		echo "aready stop"
		exit 0;
	fi

	sh gm.sh 0 stop "shutdown"
fi
