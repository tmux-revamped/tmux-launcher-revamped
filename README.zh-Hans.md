<div align="center">

# tmux-launcher-revamped

<strong>从一个菜单在 tmux 的弹出窗口、窗口或分割窗格中打开 lazygit、yazi 等终端应用，从项目根目录开始。</strong>

[English](README.md) &nbsp;|&nbsp; [日本語](README.ja.md) &nbsp;|&nbsp; 简体中文 &nbsp;|&nbsp; [繁體中文（香港）](README.zh-HK.md)

[![ci](https://img.shields.io/github/actions/workflow/status/tmux-revamped/tmux-launcher-revamped/ci.yml?branch=main&style=flat-square&label=ci)](https://github.com/tmux-revamped/tmux-launcher-revamped/actions/workflows/ci.yml)
[![release](https://img.shields.io/github/v/release/tmux-revamped/tmux-launcher-revamped?style=flat-square&label=release)](https://github.com/tmux-revamped/tmux-launcher-revamped/releases/latest)
[![openssf scorecard](https://img.shields.io/ossf-scorecard/github.com/tmux-revamped/tmux-launcher-revamped?style=flat-square&label=openssf%20scorecard)](https://scorecard.dev/viewer/?uri=github.com/tmux-revamped/tmux-launcher-revamped)
[![license](https://img.shields.io/github/license/tmux-revamped/tmux-launcher-revamped?style=flat-square&label=license)](LICENSE)

<p align="center">
  <a href="#快速开始"><strong>快速开始</strong></a> &nbsp;|&nbsp;
  <a href="#用法">用法</a> &nbsp;|&nbsp;
  <a href="#应用">应用</a> &nbsp;|&nbsp;
  <a href="#界面">界面</a>
</p>

</div>

<p align="center">
  <img src="screens/hero.gif" alt="prefix M-a 打开启动器菜单，tig 在项目根目录以弹出窗口打开" width="800">
</p>

```console
$ launcher-revamped doctor
tmux               ok       /usr/bin/tmux, 3.6
awk                ok       /usr/bin/awk, mawk 1.3.4
sed                ok       /usr/bin/sed, gnu 4.9
tr                 ok       /usr/bin/tr, uutils 0.10.0
fzf                warn     the picker needs it: brew install fzf, or apt install fzf
lazygit            warn     lazygit is not installed
yazi               warn     yazi is not installed
```

列出你使用的应用，例如 lazygit、yazi、htop 或 k9s。`prefix M-a` 打开包含全部应用的菜单，每个应用也可以有自己的按键。每个应用在弹出窗口、窗口或分割窗格中打开，位置是窗格所在的文件夹，或其上方的项目根目录。

---

## 快速开始

### 前提条件

| 工具 | 版本 | 用途 |
|:-----|:--------|:---------|
| tmux | 3.2 或更高 | 家族的最低版本；更旧的版本中弹出窗口应用会以窗口打开 |
| fzf | 任意 | 应用选择器，仅在设置了 `@launcher_revamped_picker_key` 时使用 |
| gum | 可选 | `launcher-revamped` 的菜单、表格和颜色；没有它，所有命令都输出纯文本 |

应用本身必须已安装；插件会直接运行你给出的命令。

### 安装

```tmux
set -g @plugin 'tmux-revamped/tmux-launcher-revamped'
```

然后按 `prefix + I`。不用 TPM 时，克隆仓库，并在 `~/.tmux.conf` 中运行它的入口文件：

```bash
git clone https://github.com/tmux-revamped/tmux-launcher-revamped ~/.tmux/plugins/tmux-launcher-revamped
```

```tmux
run-shell ~/.tmux/plugins/tmux-launcher-revamped/launcher-revamped.tmux
```

在克隆的目录中运行 `make install`，还会把 `launcher-revamped` 放进 `~/.local/bin`，把它的 man 手册和补全放在 `~/.local/share` 下。

### 验证

```bash
~/.tmux/plugins/tmux-launcher-revamped/bin/launcher-revamped doctor
```

## 用法

按 `prefix M-a`。菜单列出 `@launcher_revamped_apps` 中的每个应用，默认是在弹出窗口中打开的 lazygit 和在窗口中打开的 yazi。插件加载前你自己绑定的菜单按键会保留，`doctor` 会说明这一点。

| 命令 | 作用 |
|:--------|:-------------|
| `launcher-revamped apply` | 立即绑定所有按键；插件加载时入口点会运行它 |
| `launcher-revamped list` | 打印 apply 会做的每个绑定；`--json` 输出一个对象 |
| `launcher-revamped launch ID [ARG...]` | 打开应用 `ID`；后面的每个词成为一个加引号的参数 |
| `launcher-revamped pick` | 用 fzf 选择一个应用，并为 `launch-picked` 记录下来 |
| `launcher-revamped launch-picked` | 打开 `pick` 记录的应用 |
| `launcher-revamped doctor` | 每个依赖一行、每个应用一行，以及你事先绑定的菜单按键 |
| `launcher-revamped version` | 版本，然后是 tmux 版本 |
| `launcher-revamped help` | 帮助页；`man launcher-revamped` 记录相同的命令和设置 |
| `launcher-revamped` | 在终端上显示菜单 |

| tmux 选项 | 默认值 | 含义 |
|:------------|:--------|:--------|
| `@launcher_revamped_apps` | `lazygit yazi` | 菜单列出的应用 ID |
| `@launcher_revamped_menu_key` | `M-a` | 菜单的 prefix 按键；`off` 或 `none` 表示不绑定菜单 |
| `@launcher_revamped_picker_key` | 无 | fzf 应用选择器的 prefix 按键 |
| `@launcher_revamped_marker` | 无 | 标记项目根目录的文件或文件夹，例如 `.git`，用于没有自己标记的应用 |
| `@launcher_revamped_max_depth` | `20` | 标记搜索向上查找的文件夹层数 |
| `@launcher_revamped_skip_missing` | `off` | `on` 时不为命令未安装的应用绑定按键；有主机的应用不检查 |

每个选项也可以写成用短横线连接的命令选项，例如 `--menu-key M-o`，以及环境变量，例如 `LAUNCHER_REVAMPED_MENU_KEY`；命令行优先于环境变量，环境变量优先于 tmux 选项。以 tmux 选项给出的设置在启动应用时读取；通过命令行或环境变量传给 `launcher-revamped apply` 的设置会带到它绑定的按键上。空的 tmux 选项表示使用默认值。`doctor` 会指出值无法识别的设置。

3.0.0 之前这些选项名为 `@launcher_*`，旧名称已不再生效。

<a id="应用"></a>

## 应用

`@launcher_revamped_apps` 中的每个 ID 读取自己的选项 `@launcher_revamped_<id>_<field>`：

```tmux
set -g @launcher_revamped_apps 'lazygit yazi htop k9s man dash'

set -g @launcher_revamped_lazygit_key 'C-g'
set -g @launcher_revamped_lazygit_marker '.git'
set -g @launcher_revamped_lazygit_if 'git -C "$LAUNCHER_PATH" rev-parse 2>/dev/null'

set -g @launcher_revamped_htop_mode 'split'
set -g @launcher_revamped_k9s_host 'devbox'
set -g @launcher_revamped_man_prompt 'man:'
set -g @launcher_revamped_dash_group 'lazygit htop'
```

| 字段 | 默认值 | 含义 |
|:------|:--------|:--------|
| `_key` | 无 | 应用自己的 prefix 按键 |
| `_command` | ID | 运行的内容 |
| `_mode` | `popup`，yazi 为 `window` | `popup`、`window` 或 `split`；弹出窗口需要 tmux 3.2 |
| `_name` | ID | 窗口名称和菜单标签 |
| `_width`、`_height` | `80%` | 弹出窗口的大小 |
| `_marker` | 无 | 应用自己的项目标记 |
| `_if` | 无 | 先运行的 shell 检查；非零退出时应用不会打开，`LAUNCHER_PATH` 保存它将打开的文件夹 |
| `_prompt` | 无 | 先显示的提示；输入的每个词成为一个加引号的参数 |
| `_group` | 无 | 在一个新窗口中平铺打开的应用 ID |
| `_host` | 无 | 通过 `ssh -t` 运行的主机 |
| `_reuse` | `off` | `on` 时，如果同名窗口已打开就选中它 |
| `_env` | 无 | 在命令前设置的变量，例如 `A=1` |
| `_pre` | 无 | 必须先成功的命令 |
| `_exit` | 无 | 退出后运行的命令 |

带图片预览的文件管理器，例如 yazi、lf 和 ranger，更适合 `window` 模式：tmux 弹出窗口不会传递图片转义序列。

命令按 `pre && env VARS command ARGS; exit` 组合，有主机时整体包在 `ssh -t` 中。选择器在弹出窗口中运行，把选中的 ID 记录在 `@launcher_revamped_picked`；`launch-picked` 在弹出窗口关闭后打开它，因此弹出窗口应用也能打开自己的弹出窗口。

<a id="界面"></a>

## 界面

<details>
<summary>所有界面，在真实的 tmux 中用 <code>make screens</code> 录制，每个按键显示在状态栏上</summary>
<br>

<table>
<tr>
<td width="50%" valign="top"><img src="screens/menu.png" alt="launcher-revamped：prefix M-a 上的应用菜单"><br><sub>prefix M-a 上的应用菜单，来自 <code>apps.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/popup.png" alt="launcher-revamped：在项目根目录以弹出窗口打开的 tig"><br><sub>在项目根目录以弹出窗口打开的 tig，来自 <code>apps.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/window.png" alt="launcher-revamped：在独立窗口中打开的 vim"><br><sub>在独立窗口中打开的 vim，来自 <code>apps.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/split.png" alt="launcher-revamped：工作旁边的分割窗格"><br><sub>工作旁边的分割窗格，来自 <code>apps.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/prompt.png" alt="launcher-revamped：输入的词成为参数的提示"><br><sub>输入的词成为参数的提示，来自 <code>apps.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/picker.png" alt="launcher-revamped：fzf 应用选择器"><br><sub>fzf 应用选择器，来自 <code>apps.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/group.png" alt="launcher-revamped：在一个窗口中平铺的一组应用"><br><sub>在一个窗口中平铺的一组应用，来自 <code>apps.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/list.png" alt="launcher-revamped：list"><br><sub><code>list</code>，来自 <code>stills.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/json.png" alt="launcher-revamped：list --json"><br><sub><code>list --json</code>，来自 <code>stills.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/doctor.png" alt="launcher-revamped：doctor"><br><sub><code>doctor</code>，来自 <code>stills.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/plain-menu.png" alt="launcher-revamped：没有 gum 的菜单"><br><sub>没有 gum 的菜单，来自 <code>stills.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/plain-apply.png" alt="launcher-revamped：从菜单运行 apply"><br><sub>从菜单运行 <code>apply</code>，来自 <code>stills.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/version.png" alt="launcher-revamped：版本"><br><sub>版本，来自 <code>stills.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/error.png" alt="launcher-revamped：未知命令"><br><sub>未知命令，来自 <code>stills.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/themes.png" alt="launcher-revamped：六种主题下的标题"><br><sub>六种主题下的标题，来自 <code>stills.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/help.png" alt="launcher-revamped：帮助页"><br><sub>帮助页，来自 <code>themes.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/accent.png" alt="launcher-revamped：来自 LAUNCHER_REVAMPED_ACCENT 的强调色"><br><sub>来自 <code>LAUNCHER_REVAMPED_ACCENT</code> 的强调色，来自 <code>help.tape</code></sub></td>
<td width="50%" valign="top"></td>
</tr>
</table>

</details>

## 可移植性

插件是 POSIX `sh`。CI 在下面每一行上运行全部测试。

| Shell | 状态 |
|:------|:-------|
| `dash`、macOS 上的 `/bin/sh` | 支持 |
| `bash` 3.2 和 5.x、系统自带的 `zsh` 和 Homebrew 的 `zsh` | 支持 |

| 系统 | 状态 |
|:-------|:-------|
| macOS | Apple Silicon 和 Intel 上的 Tahoe，使用系统自带的工具、Homebrew 的 GNU 工具和 Homebrew 的 uutils |
| Linux | x86_64 和 arm64 上的 Ubuntu 26.04，使用 GNU coreutils、uutils 和 BusyBox |

## 开发

| 命令 | 运行内容 |
|:--------|:-------------|
| `make fmt` | 对每个脚本运行 shfmt `-i 2` |
| `make lint` | shfmt、ShellCheck、mandoc、yamllint 和 actionlint，零告警 |
| `make test` | 在系统 `sh` 下运行 bats 测试 |
| `make test-all` | 在每个已安装的 shell 下运行测试，macOS 上包括 bash 和 zsh 的两种构建 |
| `make test-linux` | 在 Ubuntu 容器中运行测试 |
| `make coverage` | 在这台 Mac 和 Ubuntu 容器中运行 bashcov，合并后以 100% 为门槛 |
| `make screens` | 用 VHS 在 tmux 中从真实插件录制上面的界面，在 macOS 上运行 |
| `make install` | 把命令、man 手册和补全安装到 `PREFIX` 下 |

在 macOS 上，运行 `brew bundle` 会根据 [`Brewfile`](Brewfile) 安装这些目标用到的所有工具。

提交遵循 Conventional Commits 格式，直接进入 `main`。`main` 上的 `ci` 通过后，`release.yml` 运行 semantic-release：自上一个标签以来的每个 `feat` 或 `fix` 都会发布新版本，更新版本常量，并把说明写进 [`CHANGELOG.md`](CHANGELOG.md)。

## 许可证

[MIT](LICENSE)，copyright Gustavo Franco。

<!-- family:begin -->

## tmux-revamped 插件家族

这个插件是 tmux-revamped 插件家族的一员。每个成员都带有 [`FAMILY.md`](FAMILY.md) 中相同的约定和相同的共享库，并且设计为一起安装：没有成员占用另一个成员占用的按键或 tmux 选项。

在一个成员中发现的缺陷，要在全部成员中排查之后才算修复完成。

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
| [`tmux-plugin-template`](https://github.com/tmux-revamped/tmux-plugin-template) | tmux-revamped 插件的起点：共享库、bats 测试框架和 CI |
| [`tmux-pomodoro-revamped`](https://github.com/tmux-revamped/tmux-pomodoro-revamped) | tmux 状态栏中的番茄钟计时器，所有状态都保存在 tmux 选项中，不使用临时文件 |
| [`tmux-ram-revamped`](https://github.com/tmux-revamped/tmux-ram-revamped) | 在 tmux 状态栏显示内存、交换空间和内存压力，在后台采样，渲染从不等待 |
| [`tmux-reorder-revamped`](https://github.com/tmux-revamped/tmux-reorder-revamped) | 用鼠标在 tmux 状态栏上拖动窗口标签来移动该窗口 |
| [`tmux-scroll-revamped`](https://github.com/tmux-revamped/tmux-scroll-revamped) | 将鼠标滚轮交给能自行滚动的应用，其他情况下进入 tmux 复制模式 |
| [`tmux-sensible-revamped`](https://github.com/tmux-revamped/tmux-sensible-revamped) | 按 tmux 版本和终端区分的合理默认设置，不改动你自己设置的选项 |
| [`tmux-tiling-revamped`](https://github.com/tmux-revamped/tmux-tiling-revamped) | tmux 的平铺窗口管理：八种布局，包括 BSP dwindle 和 spiral，并支持撤销布局 |
| [`tmux-time-revamped`](https://github.com/tmux-revamped/tmux-time-revamped) | 状态栏中的本地时钟和世界时钟，按一天中的时段着色，并提供倒计时和夏令时提醒 |
| [`tmux-weather-revamped`](https://github.com/tmux-revamped/tmux-weather-revamped) | 在后台从 wttr.in 获取天气并显示在状态栏，状态栏无需等待 |

<!-- family:end -->
