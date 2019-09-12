#!/bin/sh

if [ ! $1 -o "$1" = "help" ]; then
    echo "help"
    echo "sh make.sh macosx/linux， 平台编译"
    echo "sh make.sh clean， 清理编译"
    exit 0;
else
    cd skynet && pwd
    make $1

    cd ..

    cd 3rd && pwd
    make $1
fi