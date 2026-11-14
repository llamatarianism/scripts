#!/usr/bin/env bash

cache_file="${XDG_RUNTIME_DIR:-/tmp}/bw-fuzzel-cache"

unlock_vault () {
    password="$(fuzzel --dmenu --password='·' --prompt-only ' > ')" || return 1
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

if [[ ! -s "$cache_file" ]]; then
    names="$(bw list items --session "$BW_SESSION" | jq -r '.[] | select(.type ==1) | .name')"
    [[ -z "$names" ]] && exit 1
    (
        umask 077
        printf '%s\n' "$names" > "$cache_file"
    )
else
    names="$(< "$cache_file")"
fi

choice="$(printf '%s\n' "$names" | fuzzel --dmenu --prompt ' > ' )" || exit 0
password="$(bw get password "$choice" --session "$BW_SESSION")"

if [[ -n "$password" ]]; then
    wl-copy --paste-once <<< "$password"
    unset password
    notify-send "Bitwarden" "Copied password to clipboard."
else
    notify-send "Bitwarden" "Failed to retrieve password."
    exit 1
fi
