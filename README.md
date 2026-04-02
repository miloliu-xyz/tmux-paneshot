# tmux-paneshot

[中文](README.zh-CN.md)

Toggle a read-only scrollback snapshot in a split pane. Capture the current pane's full scrollback (with ANSI colors) and view it side-by-side — perfect for referencing long output while continuing to work.

## Features

- **Toggle** snapshot on/off with a single keybinding
- **Two directions**: right split or top split
- **Preserves colors**: captures ANSI escape sequences
- **Border label**: snapshot pane is visually tagged
- **Auto cleanup**: temp files removed when pane closes
- **Mouse scrolling**: works out of the box with `less`

## Requirements

- tmux 3.2+ (for `pane-border-status` and user options)
- [TPM](https://github.com/tmux-plugins/tpm)

## Installation

Add to your `.tmux.conf`:

```bash
set -g @plugin 'miloliu-xyz/tmux-paneshot'
```

Then press `prefix + I` to install.

## Usage

| Key | Action |
|-----|--------|
| `prefix + e` | Toggle snapshot (right split) |
| `prefix + E` | Toggle snapshot (top split) |

Press the same key again to close the snapshot. You can also press `q` inside the snapshot to close it.

## Configuration

All options are optional. Add to `.tmux.conf` before the plugin line:

```bash
# Change keybindings (default: e / E)
set -g @paneshot-key-right 'e'
set -g @paneshot-key-top 'E'

# Snapshot pane size (default: 45%)
set -g @paneshot-size '45%'

# Pager command (default: less -R --mouse)
set -g @paneshot-pager 'less -R --mouse'

# Border label text (default: Paneshot)
set -g @paneshot-border-label 'Paneshot'
```

## How It Works

1. `tmux capture-pane -peS -` grabs the full scrollback with ANSI colors
2. Content is written to a temp file and opened in a split pane via the configured pager
3. Snapshot panes are tracked using tmux user options (`@paneshot`) for reliable toggle behavior
4. Window border settings are saved before applying the snapshot label, and restored on close
5. Cleanup runs on all exit paths — keybinding toggle-off, `q` to quit pager, and stale reference recovery

## Notes

The default pager uses `less --mouse` to enable mouse wheel scrolling inside the snapshot. As a side effect, `less` captures all mouse events, so **drag-to-select text requires holding `Shift`**. This is standard behavior when tmux mouse mode is on.

If you prefer native text selection over mouse scrolling, you can disable it:

```bash
set -g @paneshot-pager 'less -R'
```

## License

MIT
