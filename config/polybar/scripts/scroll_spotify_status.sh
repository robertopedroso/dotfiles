#!/bin/bash

# see man zscroll for documentation of the following parameters
zscroll -l 100 \
        --delay 0.1 \
        --scroll 0 \
        --scroll-padding "  " \
        --match-command "$HOME/.config/polybar/scripts/get_spotify_status.sh --status" \
        --update-check true "$HOME/.config/polybar/scripts/get_spotify_status.sh" &

wait
