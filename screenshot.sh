#!/usr/bin/env bash

if [[ -z $1 ]]; then
    grim - | wl-copy
else
    slurp | grim -g - - | wl-copy
fi

exit 0
