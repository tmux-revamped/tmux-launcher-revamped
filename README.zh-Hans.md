<div align="center">

# tmux-launcher-revamped

<strong>在弹出窗口或新窗口中启动任意 TUI 应用，从当前窗格的目录开始，每个应用可配置一个按键。</strong>

[English](README.md) &nbsp;|&nbsp; [日本語](README.ja.md) &nbsp;|&nbsp; 简体中文 &nbsp;|&nbsp; [繁體中文（香港）](README.zh-HK.md)

[![Tests](https://github.com/tmux-revamped/tmux-launcher-revamped/actions/workflows/tests.yml/badge.svg)](https://github.com/tmux-revamped/tmux-launcher-revamped/actions/workflows/tests.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Version](https://img.shields.io/badge/version-2.0.0-blue.svg)](CHANGELOG.md)

<p align="center">
  <a href="#what-it-does">功能</a> &nbsp;|&nbsp;
  <a href="#installation">安装</a> &nbsp;|&nbsp;
  <a href="#usage">用法</a> &nbsp;|&nbsp;
  <a href="#configuration">配置</a> &nbsp;|&nbsp;
  <a href="#key-bindings">按键绑定</a> &nbsp;|&nbsp;
  <a href="#how-it-works">工作原理</a>
</p>

</div>

**21** 个选项，**3** 种启动模式，默认只绑定 **1** 个按键，支持 tmux **3.2** 及以上版本。

---

<a id="what-it-does"></a>

## 功能

把你常用的终端应用列出来，例如 `lazygit`、`yazi`、`htop` 或 `k9s`。每个应用会在弹出窗口、新窗口或分割窗格中打开，并从当前窗格的目录开始。

| 功能 | 选项 |
|:-----|:-----|
| 从一个菜单打开所有已列出的应用 | `@launcher_menu_key` |
| 为应用分配专用按键 | `@launcher_<id>_key` |
| 为每个应用选择弹出窗口、窗口或分割窗格 | `@launcher_<id>_mode` |
| 从项目根目录而不是窗格目录开始 | `@launcher_<id>_marker`、`@launcher_marker` |
| 检查失败时不启动 | `@launcher_<id>_if` |
| 启动前输入参数 | `@launcher_<id>_prompt` |
| 在一个平铺窗口中同时打开多个应用 | `@launcher_<id>_group` |
| 通过 `ssh -t` 在另一台主机上运行应用 | `@launcher_<id>_host` |
| 用 fzf 选择应用 | `@launcher_picker_key` |

<a id="requirements"></a>

## 环境要求

| 依赖 | 版本 |
|:-----|:-----|
| tmux | 3.2 及以上 |
| bash | 3.2 及以上 |
| fzf | 任意版本，仅 `@launcher_picker_key` 需要 |

可在 Linux 和 macOS 上运行，支持 BSD、GNU 或 uutils coreutils。要启动的应用需要自行安装，插件只会运行你指定的命令。

<a id="installation"></a>

## 安装

使用 [TPM](https://github.com/tmux-plugins/tpm) 时，把插件加入 `~/.tmux.conf`，然后按 `prefix + I`：

```tmux
set -g @plugin 'tmux-revamped/tmux-launcher-revamped'
```

手动安装时，克隆仓库，并在 `~/.tmux.conf` 中运行入口脚本：

```bash
git clone https://github.com/tmux-revamped/tmux-launcher-revamped ~/.tmux/plugins/tmux-launcher-revamped
```

```tmux
run-shell ~/.tmux/plugins/tmux-launcher-revamped/launcher-revamped.tmux
```

<a id="usage"></a>

## 用法

按 `prefix + M-a`，菜单会列出 `@launcher_apps` 中的所有应用。默认是在弹出窗口中打开的 `lazygit` 和在窗口中打开的 `yazi`。

添加你自己的应用，并为最常用的应用分配专用按键：

```tmux
set -g @launcher_apps 'lazygit yazi lazydocker htop k9s'

set -g @launcher_lazygit_key 'C-g'
set -g @launcher_yazi_key 'C-y'
set -g @launcher_htop_key 'C-t'
set -g @launcher_htop_mode 'split'
```

更多启动选项：

```tmux
set -g @launcher_lazygit_if 'git -C "$LAUNCHER_PATH" rev-parse 2>/dev/null'
set -g @launcher_lazygit_marker '.git'
set -g @launcher_lazygit_exit 'tmux refresh-client -S'

set -g @launcher_man_key 'C-m'
set -g @launcher_man_prompt 'man:'

set -g @launcher_dash_key 'C-d'
set -g @launcher_dash_group 'lazygit htop'

set -g @launcher_k9s_key 'C-s'
set -g @launcher_k9s_host 'box.example'

set -g @launcher_picker_key 'C-p'
set -g @launcher_skip_missing 'on'
```

`yazi`、`lf`、`ranger` 等显示图片预览的文件管理器更适合使用 `window` 模式，因为 tmux 弹出窗口不会转发图片转义序列（[tmux#4329](https://github.com/tmux/tmux/issues/4329)）。

<a id="configuration"></a>

## 配置

`@launcher_apps` 是以空格分隔的应用 ID 列表。每个 ID 读取下面的应用级选项。

### 全局选项

| 选项 | 默认值 | 含义 |
|:-----|:-------|:-----|
| `@launcher_apps` | `lazygit yazi` | 显示在菜单中并检查专用按键的应用 ID |
| `@launcher_menu_key` | `M-a` | 打开所有应用的 `display-menu` 的 prefix 按键；设为 `off` 则取消绑定 |
| `@launcher_picker_key` | 无 | 在弹出窗口中打开 fzf 应用选择器的 prefix 按键 |
| `@launcher_marker` | 无 | 没有自己标记的应用所使用的标记文件或目录 |
| `@launcher_max_depth` | `20` | 查找标记时向上搜索的父目录层数 |
| `@launcher_skip_missing` | off | 设为 `on` 时，命令不在 `PATH` 中的应用不绑定专用按键；设置了主机的应用不做检查 |

### 应用级选项

| 选项 | 默认值 | 含义 |
|:-----|:-------|:-----|
| `@launcher_<id>_key` | 无 | 该应用的 prefix 按键；设置之前不会绑定任何按键 |
| `@launcher_<id>_command` | 与 ID 相同 | 要运行的 shell 命令 |
| `@launcher_<id>_mode` | `popup`，`yazi` 为 `window` | `popup`、`window` 或 `split` |
| `@launcher_<id>_name` | 与 ID 相同 | `window` 模式下的窗口名，以及菜单中的标签 |
| `@launcher_<id>_width` | `80%` | 弹出窗口宽度 |
| `@launcher_<id>_height` | `80%` | 弹出窗口高度 |
| `@launcher_<id>_marker` | 无 | 从窗格目录向上查找包含该标记（例如 `.git`）的目录；找不到时使用窗格目录 |
| `@launcher_<id>_if` | 无 | 启动前运行的 shell 判断；退出码非零则取消启动。`LAUNCHER_PATH` 保存起始目录 |
| `@launcher_<id>_prompt` | 无 | 提示文字；输入的每个单词都会作为带引号的参数追加到命令后 |
| `@launcher_<id>_group` | 无 | 以空格分隔的应用 ID，在一个新窗口中打开并平铺 |
| `@launcher_<id>_host` | 无 | 远程主机；组合后的命令通过 `ssh -t` 运行 |
| `@launcher_<id>_reuse` | off | 在 `window` 模式下设为 `on` 时，选中同名窗口而不是再打开一个 |
| `@launcher_<id>_env` | 无 | 用 `env` 放在命令前的变量，例如 `FOO=bar` |
| `@launcher_<id>_pre` | 无 | 先运行的命令；只有它成功时才启动应用 |
| `@launcher_<id>_exit` | 无 | 应用退出后运行的命令 |

### 内部状态

以下选项由插件自己写入，请勿设置。

| 选项 | 保存内容 |
|:-----|:---------|
| `@launcher_prompt_value` | 在应用提示中输入的文字，启动时读取一次 |
| `@launcher_picked` | 在 fzf 选择器中选中的应用，启动后清除 |

<a id="key-bindings"></a>

## 按键绑定

| 按键 | 操作 | 默认 |
|:-----|:-----|:-----|
| `prefix + M-a` | `@launcher_apps` 中所有应用的菜单 | 已绑定 |
| `@launcher_<id>_key` | 启动该应用 | 未绑定 |
| `@launcher_picker_key` | fzf 应用选择器 | 未绑定 |

2.0.0 版移除了以前的专用按键。要恢复它们：

```tmux
set -g @launcher_lazygit_key 'C-g'
set -g @launcher_yazi_key 'C-y'
```

<a id="how-it-works"></a>

## 工作原理

tmux 加载插件时，[`launcher-revamped.tmux`](launcher-revamped.tmux) 会运行一次 [`src/launcher.sh`](src/launcher.sh)。该脚本读取选项，并绑定菜单、选择器和每个应用的按键。每个绑定都通过 `run-shell -b` 以 `dispatch <id>` 回调同一个脚本，所以实际工作在按下按键时才进行。

启动时，`dispatch` 确定起始目录，运行 `_if` 判断，然后按以下顺序组合命令：`pre &&`、`env` 变量、命令及其提示参数、`; exit`。设置主机后，整个结果会用 `ssh -t` 包装。模式决定使用 `display-popup -E`、`new-window` 还是 `split-window`。在没有 `display-popup` 的 tmux 3.2 以下版本中，弹出窗口应用会改为在窗口中打开。

fzf 选择器在 `display-popup -E` 中运行，把选中的 ID 保存到 `@launcher_picked`，并在弹出窗口关闭后启动它。这样弹出窗口应用也能打开自己的弹出窗口。

纯函数辅助代码位于 [`src/lib/launcher/launcher.sh`](src/lib/launcher/launcher.sh)。设置 `LAUNCHER_DRY_RUN` 后，脚本会打印每个 tmux 调用而不执行，测试套件就是用这种方式检查按键绑定的。

<a id="development"></a>

## 开发

| 命令 | 作用 |
|:-----|:-----|
| `make test` | 运行 bats 测试套件 |
| `make lint` | 对所有 shell 文件运行 shellcheck |
| `make coverage` | 在 Linux 上用 kcov 测量行覆盖率，低于 95% 时失败 |

变更记录见 [CHANGELOG.md](CHANGELOG.md)。

<a id="license"></a>

## 许可证

[MIT](LICENSE)

<!-- family:begin -->

## tmux-revamped 插件家族

本插件是 tmux-revamped 插件家族的一员。每个成员都带有 [`FAMILY.md`](FAMILY.md) 中的同一份约定、`family/` 下的同一套工具和同一个共享库，并由校验和清单保证逐字节一致。这些成员可以一起安装：任何成员都不会占用其他成员使用的按键或 tmux 选项。

在一个成员中发现的缺陷，要在全部成员中排查之后才算修复完成。这项义务写在约定里，而不是靠记忆，`family/bin/sweep` 负责执行它。

| 成员 | 功能 |
|---|---|
| [`tmux-autoreload-revamped`](https://github.com/tmux-revamped/tmux-autoreload-revamped) | 编辑并保存 tmux 配置后，它会自动重新加载，无需按键，也无需命令 |
| [`tmux-battery-revamped`](https://github.com/tmux-revamped/tmux-battery-revamped) | 在 tmux 状态栏显示电池状态，从不阻塞状态栏渲染 |
| [`tmux-bluetooth-revamped`](https://github.com/tmux-revamped/tmux-bluetooth-revamped) | 在 tmux 状态栏显示每个已连接的蓝牙设备及其电量，不阻塞渲染 |
| [`tmux-cpu-revamped`](https://github.com/tmux-revamped/tmux-cpu-revamped) | 在 tmux 状态栏显示 CPU 负载、温度和频率，从不阻塞渲染 |
| [`tmux-disk-revamped`](https://github.com/tmux-revamped/tmux-disk-revamped) | 在 tmux 状态栏显示磁盘用量，从不阻塞状态栏渲染 |
| [`tmux-extract-revamped`](https://github.com/tmux-revamped/tmux-extract-revamped) | 用 fzf 从屏幕上挑选 URL、路径、哈希或任意其他词元，并输入到光标处，全部用纯 shell 实现 |
| [`tmux-fzf-revamped`](https://github.com/tmux-revamped/tmux-fzf-revamped) | 在弹出窗口中的 fzf 选择器里切换、关闭、重命名或创建 tmux 会话、窗口和窗格 |
| [`tmux-git-revamped`](https://github.com/tmux-revamped/tmux-git-revamped) | 在 tmux 状态栏中显示活动窗格的 git 分支、改动和托管平台计数，且不阻塞渲染 |
| [`tmux-gpu-revamped`](https://github.com/tmux-revamped/tmux-gpu-revamped) | 在 tmux 状态栏中显示 NVIDIA、AMD、Intel 和 Apple GPU 的负载、温度、频率、功耗和显存 |
| [`tmux-kube-revamped`](https://github.com/tmux-revamped/tmux-kube-revamped) | 在 tmux 状态栏中显示当前的 Kubernetes 上下文和命名空间，不依赖 kubectl，直接解析 kubeconfig |
| [`tmux-launcher-revamped`](https://github.com/tmux-revamped/tmux-launcher-revamped) | **本插件**，在弹出窗口或新窗口中启动任意 TUI 应用，从当前窗格的目录开始，每个应用可配置一个按键 |
| [`tmux-logging-revamped`](https://github.com/tmux-revamped/tmux-logging-revamped) | 将任意窗格保存到文件：实时日志、完整回滚缓冲区或一次性截图 |
| [`tmux-music-revamped`](https://github.com/tmux-revamped/tmux-music-revamped) | 在 tmux 状态栏显示正在播放的曲目，从不阻塞状态栏渲染 |
| [`tmux-network-revamped`](https://github.com/tmux-revamped/tmux-network-revamped) | 在 tmux 状态栏显示网络吞吐量，从不阻塞渲染 |
| [`tmux-pain-control-revamped`](https://github.com/tmux-revamped/tmux-pain-control-revamped) | tmux 的窗格和窗口管理按键，适配 tmux 版本，兼容 vim，每个 prefix 按键都可禁用 |
| [`tmux-persist-revamped`](https://github.com/tmux-revamped/tmux-persist-revamped) | 保存 tmux 的所有会话、窗口和窗格，按定时器自动保存，并在重启后全部恢复 |
| [`tmux-plugin-template`](https://github.com/tmux-revamped/tmux-plugin-template) | tmux-revamped 插件的起点：共享库、bats 测试框架、CI 和系列工具 |
| [`tmux-pomodoro-revamped`](https://github.com/tmux-revamped/tmux-pomodoro-revamped) | tmux 状态栏中的番茄钟计时器，所有状态都保存在 tmux 选项中，不使用临时文件 |
| [`tmux-ram-revamped`](https://github.com/tmux-revamped/tmux-ram-revamped) | 在 tmux 状态栏显示内存、交换空间和内存压力，在后台采样，渲染从不等待 |
| [`tmux-reorder-revamped`](https://github.com/tmux-revamped/tmux-reorder-revamped) | 用鼠标在 tmux 状态栏上拖动窗口标签来移动该窗口 |
| [`tmux-scroll-revamped`](https://github.com/tmux-revamped/tmux-scroll-revamped) | 将鼠标滚轮交给能自行滚动的应用，其他情况下进入 tmux 复制模式 |
| [`tmux-sensible-revamped`](https://github.com/tmux-revamped/tmux-sensible-revamped) | 按 tmux 版本和终端区分的合理默认设置，不改动你自己设置的选项 |
| [`tmux-tiling-revamped`](https://github.com/tmux-revamped/tmux-tiling-revamped) | tmux 的平铺窗口管理：八种布局，包括 BSP dwindle 和 spiral，并支持撤销布局 |
| [`tmux-time-revamped`](https://github.com/tmux-revamped/tmux-time-revamped) | 状态栏中的本地时钟和世界时钟，按一天中的时段着色，并提供倒计时和夏令时提醒 |
| [`tmux-weather-revamped`](https://github.com/tmux-revamped/tmux-weather-revamped) | 在后台从 wttr.in 获取天气并显示在状态栏，状态栏无需等待 |

### 检查安装

所有成员都在磁盘上时，一条命令即可报告它们之间的任何冲突：

```sh
family/bin/doctor --live
```

它读取每个成员和正在运行的 tmux 服务器，报告重复的按键、重复的状态占位符、不符合命名规则的选项，以及约定版本落后的成员。

<!-- family:end -->
