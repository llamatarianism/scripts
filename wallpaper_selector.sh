#!/usr/bin/env bash
pkill -x fuzzel
pkill -x nsxiv
wallpath="$(nsxiv -to "${WALLPAPER_DIR:-$HOME/Pictures/Wallpapers}")"


if [[ "$wallpath" =~ [[:space:]] ]]; then
    echo "ERROR: Multiple wallpapers selected in nsxiv"
    exit 1
elif [[ -n "$wallpath" ]]; then
    pid="$(pgrep swaybg)"
    swaybg -i "$wallpath" -m fill &
    sleep 1
    if [[ -n "$pid" ]]; then
        printf '%s\n' "$pid" | xargs -r kill 2>/dev/null
    fi
else
    echo "ERROR: No wallpaper selected"
    exit 1
fi
