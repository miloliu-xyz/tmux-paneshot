# tmux-paneshot

在 tmux 分屏中打开当前 pane 的只读滚动历史快照。一键捕获完整 scrollback（保留 ANSI 颜色），并排查看——非常适合在终端 AI 工具（如 Claude Code）中回看长输出的同时继续对话。

## 功能

- **Toggle 开关**：同一快捷键打开/关闭快照
- **两个方向**：右侧分屏或上方分屏
- **保留颜色**：完整捕获 ANSI 转义序列
- **边框标签**：快照 pane 有可视标识
- **自动清理**：关闭后临时文件自动删除
- **鼠标滚动**：`less` 原生支持鼠标滚轮

## 环境要求

- tmux 3.2+（需要 `pane-border-status` 和 user options 支持）
- [TPM](https://github.com/tmux-plugins/tpm)

## 安装

在 `.tmux.conf` 中添加：

```bash
set -g @plugin 'miloliu-xyz/tmux-paneshot'
```

然后按 `prefix + I` 安装。

## 使用

| 快捷键 | 操作 |
|--------|------|
| `prefix + e` | 右侧快照（toggle） |
| `prefix + E` | 上方快照（toggle） |

再按一次关闭快照，也可以在快照中按 `q` 退出。

## 配置

所有选项均为可选，在 `.tmux.conf` 中插件声明之前设置：

```bash
# 自定义快捷键（默认：e / E）
set -g @paneshot-key-right 'e'
set -g @paneshot-key-top 'E'

# 快照 pane 占比（默认：45%）
set -g @paneshot-size '45%'

# 分页器命令（默认：less -R --mouse）
set -g @paneshot-pager 'less -R --mouse'

# 边框标签文字（默认：Paneshot）
set -g @paneshot-border-label 'Paneshot'
```

## 工作原理

1. `tmux capture-pane -peS -` 抓取完整 scrollback，`-e` 保留 ANSI 颜色
2. 内容写入临时文件，通过分屏用 pager 打开
3. 使用 tmux user option（`@paneshot`）标记快照 pane，确保 toggle 行为可靠
4. 打开快照前保存窗口的 border 设置，关闭时恢复原状
5. 三条退出路径（快捷键 toggle-off、`q` 退出 pager、孤儿引用恢复）统一调用 `cleanup.sh` 清理状态

## 注意事项

默认 pager 使用 `less --mouse` 以支持鼠标滚轮翻页。副作用是 `less` 会接管所有鼠标事件，**拖拽选择文本时需要按住 `Shift`**。这是 tmux mouse mode 下的标准行为。

如果你更需要原生文本选择而非鼠标滚轮，可以关闭它：

```bash
set -g @paneshot-pager 'less -R'
```

## 许可证

MIT
