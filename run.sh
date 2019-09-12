#!/bin/sh

if [ ! $1 -o "$1" = "help" ]; then
    echo "help"
    echo "sh run.sh make macosx/linux， 平台编译"
    echo "sh run.sh make clean， 清理编译"
    echo "sh run.sh status node， 节点状态"
    echo "sh run.sh start node， 运行节点"
    echo "sh run.sh restart node， 重启节点"
    echo "sh run.sh stop node， 停止节点"
    echo "sh run.sh kill node， 杀死节点进程"
    echo "sh run.sh gm 玩家ID 指令 参数..."
    echo "sh run.sh sendmail"
    exit 0;
else
    scriptfile="./tools/shell/$1.sh"
    if [ ! -f $scriptfile ]; then
        echo "script file not exist: $scriptfile"
        exit 0;
    fi

    sh $scriptfile $2 $3
fi