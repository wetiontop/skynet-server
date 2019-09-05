#!/bin/sh

root=$(cd `dirname $0`; pwd)

if [ ! $1 ]; then
    cmd='help'
else
    cmd=$1
fi

if [ $cmd = "help" ]; then
    echo "help"
    echo "run.sh make macosx， 平台编译"
    echo "run.sh make clean， 清理编译"
    echo "run.sh kill， 杀死全部进程"
    echo "run.sh kill node， 杀死节点进程"
    echo "run.sh node， 运行节点"
    echo "run.sh node daemon， 运行节点并开启后台模式"
elif [ $cmd == "make" ]; then
    if [ $2 -a $2 == "clean" ]; then
        echo "\n clean skynet"
        cd $root/skynet && pwd
        make clean

        echo "\n clean 3rd"
        cd $root/3rd && pwd
        make clean
    else
        platform=macosx
        if [ $2 ]; then
            platform=$2
        fi
        echo "\n make skynet"
        cd $root/skynet && pwd
        make $platform

        echo "\n make 3rd"
        cd $root/3rd  && pwd
        make $platform
    fi
elif [ $cmd == "kill" ]; then
    if [ $2 ]; then
	    ps -ef | grep skynet | grep $2 | awk '{print $2}' | xargs kill -9
        echo "kill $2 ok"
    else
        pkill -9 skynet
        echo "kill all ok"
    fi
    exit 0;
else
    export DAEMON=false
    if [ $2 -a $2 == "daemon" ]; then
        DAEMON=true
    fi
    echo "run $cmd and set daemon for $DAEMON"
    $root/skynet/skynet $root/etc/config.$1
fi