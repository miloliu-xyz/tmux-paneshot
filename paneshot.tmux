#!/usr/bin/env bash

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source "$CURRENT_DIR/scripts/helpers.sh"

key_right=$(get_tmux_option "@paneshot-key-right" "e")
key_top=$(get_tmux_option "@paneshot-key-top" "E")

tmux bind-key "$key_right" run-shell "$CURRENT_DIR/scripts/toggle.sh right"
tmux bind-key "$key_top" run-shell "$CURRENT_DIR/scripts/toggle.sh top"
