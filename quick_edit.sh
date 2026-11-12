#!/usr/bin/env bash
pkill fuzzel
pkill nsxiv
file=$(find .* * -maxdepth 0 | fuzzel --dmenu -w 60 -l 5 -p " > ")

while :
do
    if [ -z $file ]; then
        exit 0
    elif [ -d $file ]; then
        file=$(find $file/* -maxdepth 0 | fuzzel --dmenu -w 60 -l 5 -p " > ")
    else
        kitty -e $EDITOR $file
        exit 0
    fi
done
