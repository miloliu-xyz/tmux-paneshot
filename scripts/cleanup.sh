#!/usr/bin/env bash
# cleanup.sh: restore window state after snapshot pane closes
# Called from both toggle-off (keybinding) and pager exit (q) paths

win_id="$1"
tmpfile="${2:-}"

[[ -n "$tmpfile" ]] && rm -f "$tmpfile"

# Restore previous border settings
prev_status=$(tmux show-options -wqv -t "$win_id" @paneshot_prev_border_status 2>/dev/null)
prev_format=$(tmux show-options -wqv -t "$win_id" @paneshot_prev_border_format 2>/dev/null)
if [[ -n "$prev_status" ]]; then
    tmux set-option -w -t "$win_id" pane-border-status "$prev_status" 2>/dev/null
else
    tmux set-option -wqu -t "$win_id" pane-border-status 2>/dev/null
fi
if [[ -n "$prev_format" ]]; then
    tmux set-option -w -t "$win_id" pane-border-format "$prev_format" 2>/dev/null
else
    tmux set-option -wqu -t "$win_id" pane-border-format 2>/dev/null
fi

# Clean up all paneshot window options
tmux set-option -wqu -t "$win_id" @paneshot_pane 2>/dev/null
tmux set-option -wqu -t "$win_id" @paneshot_prev_border_status 2>/dev/null
tmux set-option -wqu -t "$win_id" @paneshot_prev_border_format 2>/dev/null
