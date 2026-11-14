#!/usr/bin/env bash

unlock_vault () {
    password="$(fuzzel --dmenu --password='·' --prompt-only ' > ')" 
    key="$(printf '%s\n' "$password" | bw unlock --raw)" 
    unset password
    if [[ -z "$key" ]]; then
        notify-send "Bitwarden" "Failed to unlock vault."
        return 1
    fi
    printf '%s' "$key"
}

pkill fuzzel
pkill nsxiv

BW_SESSION="$(secret-tool lookup bitwarden sessionkey)"

if [[ -z "$BW_SESSION" ]]; then
    BW_SESSION="$(unlock_vault)" || exit 0
    printf "%s" "$BW_SESSION" | secret-tool store \
        --collection=/org/freedesktop/secrets/collection/session \
        --label='Bitwarden session key' bitwarden sessionkey
fi

items="$(bw list items --session "$BW_SESSION" | jq '.[] | select(.type == 1)')"
names="$(printf '%s' "$items" | jq -r '.name')"
choice="$(printf '%s\n' "$names" | fuzzel --dmenu --prompt ' > ' )" || exit 0
password=$(printf '%s' "$items" | jq -r --arg name "$choice" 'select(.name == $name) | .login .password')

if [[ -n "$password" ]]; then
    wl-copy --paste-once <<< "$password"
    unset password
    notify-send "Bitwarden" "Copied password to clipboard."
else
    notify-send "Bitwarden" "Failed to retrieve password."
    exit 1
fi
