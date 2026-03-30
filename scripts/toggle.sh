#!/usr/bin/env bash
# toggle.sh: toggle a read-only scrollback snapshot in a split pane

set -euo pipefail

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$CURRENT_DIR/helpers.sh"

dir="${1:-right}"
size=$(get_tmux_option "@paneshot-size" "45%")
pager=$(get_tmux_option "@paneshot-pager" "less -R --mouse")
label=$(get_tmux_option "@paneshot-border-label" "Paneshot")

win_id=$(tmux display-message -p '#{window_id}')
src_pane=$(tmux display-message -p '#{pane_id}')
snapshot=$(tmux show-options -wqv -t "$win_id" @paneshot_pane)

# If snapshot pane exists and is alive, kill it
if [[ -n "$snapshot" ]] && tmux display-message -t "$snapshot" -p '' 2>/dev/null; then
    tmux kill-pane -t "$snapshot"
    "$CURRENT_DIR/cleanup.sh" "$win_id"
    exit 0
fi

# Stale reference — clean up (covers the "q to quit pager" path on next toggle)
if [[ -n "$snapshot" ]]; then
    "$CURRENT_DIR/cleanup.sh" "$win_id"
fi

# Capture scrollback with ANSI colors
tmpfile=$(mktemp /tmp/tmux-paneshot.XXXXXX)
trap 'rm -f "$tmpfile"' EXIT

tmux capture-pane -t "$src_pane" -peS - > "$tmpfile"

# Save current border settings before overwriting
prev_status=$(tmux show-options -wqv -t "$win_id" pane-border-status)
prev_format=$(tmux show-options -wqv -t "$win_id" pane-border-format)
[[ -n "$prev_status" ]] && tmux set-option -w -t "$win_id" @paneshot_prev_border_status "$prev_status"
[[ -n "$prev_format" ]] && tmux set-option -w -t "$win_id" @paneshot_prev_border_format "$prev_format"

# Split and open snapshot pane — cleanup.sh runs when pager exits
case "$dir" in
    right) new_pane=$(tmux split-window -h -l "$size" -t "$src_pane" -P -F '#{pane_id}' \
        "$pager +G '$tmpfile'; '$CURRENT_DIR/cleanup.sh' '$win_id' '$tmpfile'") ;;
    top)   new_pane=$(tmux split-window -v -b -l "$size" -t "$src_pane" -P -F '#{pane_id}' \
        "$pager +G '$tmpfile'; '$CURRENT_DIR/cleanup.sh' '$win_id' '$tmpfile'") ;;
    *)     echo "Usage: toggle.sh right|top" >&2; exit 1 ;;
esac

# split-window succeeded — cleanup.sh will handle tmpfile
trap - EXIT

# Tag the snapshot pane and apply border label
tmux set-option -p -t "$new_pane" @paneshot 1
tmux set-option -w -t "$win_id" @paneshot_pane "$new_pane"
tmux set-option -w -t "$win_id" pane-border-status top
tmux set-option -w -t "$win_id" pane-border-format "#{?@paneshot, $label ,}"
