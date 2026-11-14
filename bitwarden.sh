#!/usr/bin/env bash

unlock_vault () {
    password="$(fuzzel --dmenu --password --prompt-only ' > ')" 
    key="$(printf '%s\n' "$password" | bw unlock --raw)"
    unset password
    printf '%s' "$key"
}

BW_SESSION="$(secret-tool lookup bitwarden sessionkey)"

if [[ -z "$BW_SESSION" ]]; then
    BW_SESSION="$(unlock_vault)"
    printf "%s" "$BW_SESSION" | secret-tool store --collection=/org/freedesktop/secrets/collection/session --label='Bitwarden session key' bitwarden sessionkey
fi

items="$(bw list items --session "$BW_SESSION" | jq -r '.[] | "\(.name)"')"

choice="$(printf '%s\n' "$items" | fuzzel --dmenu --prompt ' > ' )"
[[ -z "$choice" ]] && exit 0

if password="$(bw get password "$choice" --session "$BW_SESSION")"; then
    wl-copy --paste-once <<< "$password"
    unset password
    notify-send "Bitwarden" "Copied password to clipboard."
else
    notify-send "Bitwarden" "Failed to retrieve password."
    exit 1
fi
