#!/usr/bin/env bash
set -euo pipefail

port=8087
api="http://127.0.0.1:$port"

pkill fuzzel 2>/dev/null || true
pkill nsxiv 2>/dev/null || true

if ! curl -sf "$api/status" >/dev/null 2>&1; then
    nohup bw serve --hostname 127.0.0.1 --port "$port" >/dev/null 2>&1 &
    started=false
    for _ in {1..30}; do
        if curl -sf "$api/status" >/dev/null 2>&1; then
            started=true
            break
        fi
        sleep 0.1
    done
    if [[ "$started" != "true" ]]; then
        notify-send "Bitwarden" "Failed to start bw serve."
        exit 1
    fi
fi

status="$(curl -sf "$api/status" | jq -r '.data.template.status')"

if [[ "$status" != "unlocked" ]]; then
    
    master_pass="$(fuzzel --dmenu --password='·' --prompt-only ' > ')" || exit 0
    [[ -z "$master_pass" ]] && exit 0

    res="$(jq -nc --arg pw "$master_pass" '{password: $pw}' | \
        curl -s -X POST "$api/unlock" -H "Content-Type: application/json" -d @-)"

    unset master_pass

    if [[ "$(jq -r '.success // false' <<< "$res")" != "true" ]]; then
        notify-send "Bitwarden" "Failed to unlock vault."
        exit 1
    fi
fi

mapfile -t entries < <(
    curl -sf "$api/list/object/items" | jq -r '
        .data.data[] | select(.type == 1 and (.login.password // "") != "")
        | "\(.name) (\(.login.username // "no user"))\t\(.id)"
    '
)

idx="$(printf '%s\n' "${entries[@]%%$'\t'*}" | fuzzel --dmenu --index --prompt ' > ')" || exit 0
item_id="${entries[$idx]#*$'\t'}"

password="$(curl -sf "$api/object/password/$item_id" | jq -r '.data.data // empty')"

if [[ -n "$password" ]]; then
    printf -- '%s' "$password" | wl-copy --paste-once
    unset password
    notify-send "Bitwarden" "Copied password to clipboard."

    (
        sleep 60
        wl-copy --clear 2>/dev/null || true
    ) &
else
    notify-send "Bitwarden" "Failed to retrieve password."
    exit 1
fi
