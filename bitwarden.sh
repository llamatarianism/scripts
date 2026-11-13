#!/usr/bin/env bash

unlock_vault () {
    password="$(fuzzel --dmenu --password --prompt-only "Unlock > ")"
    
    if [[ -z "$password" ]]; then
        exit 1
    fi
    
    key="$(printf '%s\n' "$password" | bw unlock --raw)"
    unset password
    
    if [[ -z "$key" ]]; then
        notify-send "Bitwarden" "Failed to unlock vault."
        exit 1
    fi

    printf '%s' "$key"
}

BW_SESSION="$(secret-tool lookup bitwarden sessionkey)"

if [[ -z "$BW_SESSION" ]]; then
    BW_SESSION="$(unlock_vault)"
    printf "%s" "$BW_SESSION" | secret-tool store --collection=/org/freedesktop/secrets/collection/session --label='Bitwarden session key' bitwarden sessionkey
fi

items=$(bw list items --session '$BW_SESSION' | jq -r '.[] | "\(.name)"')

bw get password "$(printf '%s\n' "$items" | fuzzel --dmenu)" --session $BW_SESSION | wl-copy --paste-once
notify-send "Bitwarden" "Copied to clipboard."
