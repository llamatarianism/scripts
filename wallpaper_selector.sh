#!/usr/bin/env bash
pkill fuzzel
pkill nsxiv
wallpath=$(nsxiv -to "${WALLPAPER_DIR:-$HOME/Pictures/Wallpapers}")


if [[ $wallpath =~ [[:space:]] ]]; then
    echo "ERROR: Multiple wallpapers selected in nsxiv"
    exit 1
elif [[ -n $wallpath ]]; then
    pid=$(pgrep swaybg)
    echo $pid
    swaybg -i $wallpath &
    sleep 1
    if [[ -n $pid ]]; then
        kill $pid
    fi
else
    echo "ERROR: No wallpaper selected"
    exit 1
fi
