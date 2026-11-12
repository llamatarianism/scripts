#!/usr/bin/env bash
pkill fuzzel
pkill nsxiv
choice=$(printf "Lock\nLogout\nReboot\nShutdown" | fuzzel --dmenu -p "󰐥 > " -l 4)

are_you_sure () {
    confirm=$(printf "Yes\nNo" | fuzzel --dmenu -p "$1 > " -l 2)
    case $confirm in
        Yes)
            return
            ;;
        No)
            exit 0
            ;;
        *)
            exit 1
            ;;
    esac
}

case $choice in
    Lock)
        are_you_sure $choice
        swaylock
        ;;
    Logout)
        are_you_sure $choice
        loginctl terminate-session $XDG_SESSION_ID
        ;;
    Reboot)
        are_you_sure $choice
        reboot
        ;;
    Shutdown)
        are_you_sure $choice
        shutdown
        ;;
    "")
        exit 0
        ;;
    *)
        exit 1
        ;;
esac
