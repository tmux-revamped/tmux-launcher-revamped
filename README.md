<div align="center">

# tmux-launcher-revamped

<strong>Launch any TUI app in a popup or a window, scoped to the current pane's directory, with one configurable binding per app.</strong>

English | [日本語](README.ja.md) | [简体中文](README.zh-Hans.md) | [繁體中文（香港）](README.zh-HK.md)

[![Tests](https://github.com/tmux-revamped/tmux-launcher-revamped/actions/workflows/tests.yml/badge.svg)](https://github.com/tmux-revamped/tmux-launcher-revamped/actions/workflows/tests.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Version](https://img.shields.io/badge/version-2.0.0-blue.svg)](CHANGELOG.md)

<p align="center">
  <a href="#what-it-does">What it does</a> |
  <a href="#installation">Installation</a> |
  <a href="#usage">Usage</a> |
  <a href="#configuration">Configuration</a> |
  <a href="#key-bindings">Key bindings</a> |
  <a href="#how-it-works">How it works</a>
</p>

</div>

**21** options, **3** launch modes, **1** key bound by default, tmux **3.2** or later.

---

## What it does

You list the terminal apps you use, such as `lazygit`, `yazi`, `htop` or `k9s`. Each one opens in a popup, a new window or a split, and starts in the current pane's directory.

| Capability | Option |
|:-----------|:-------|
| Open every listed app from one menu | `@launcher_menu_key` |
| Give an app its own key | `@launcher_<id>_key` |
| Pick popup, window or split per app | `@launcher_<id>_mode` |
| Start at the project root instead of the pane directory | `@launcher_<id>_marker`, `@launcher_marker` |
| Skip the launch when a check fails | `@launcher_<id>_if` |
| Ask for arguments before launching | `@launcher_<id>_prompt` |
| Open several apps as one tiled window | `@launcher_<id>_group` |
| Run the app on another host over `ssh -t` | `@launcher_<id>_host` |
| Choose an app with fzf | `@launcher_picker_key` |

## Requirements

| Requirement | Version |
|:------------|:--------|
| tmux | 3.2 or later |
| bash | 3.2 or later |
| fzf | any, only for `@launcher_picker_key` |

It runs on Linux and macOS with BSD, GNU or uutils coreutils. The apps you launch must be installed; the plugin runs whatever command you give it.

## Installation

With [TPM](https://github.com/tmux-plugins/tpm), add the plugin to `~/.tmux.conf` and press `prefix + I`:

```tmux
set -g @plugin 'tmux-revamped/tmux-launcher-revamped'
```

To install by hand, clone the repository and run the entrypoint from `~/.tmux.conf`:

```bash
git clone https://github.com/tmux-revamped/tmux-launcher-revamped ~/.tmux/plugins/tmux-launcher-revamped
```

```tmux
run-shell ~/.tmux/plugins/tmux-launcher-revamped/launcher-revamped.tmux
```

## Usage

Press `prefix + M-a`. A menu lists every app in `@launcher_apps`, which defaults to `lazygit` in a popup and `yazi` in a window.

Add your own apps and give the ones you use most a direct key:

```tmux
set -g @launcher_apps 'lazygit yazi lazydocker htop k9s'

set -g @launcher_lazygit_key 'C-g'
set -g @launcher_yazi_key 'C-y'
set -g @launcher_htop_key 'C-t'
set -g @launcher_htop_mode 'split'
```

More launch options:

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

File managers that show image previews, such as `yazi`, `lf` and `ranger`, work better in `window` mode. tmux popups do not pass image escape sequences through ([tmux#4329](https://github.com/tmux/tmux/issues/4329)).

## Configuration

`@launcher_apps` is a space-separated list of app ids. Each id reads the per-app options below.

### Global options

| Option | Default | Meaning |
|:-------|:--------|:--------|
| `@launcher_apps` | `lazygit yazi` | App ids shown in the menu and checked for a direct key |
| `@launcher_menu_key` | `M-a` | Prefix key that opens a `display-menu` of every app; `off` unbinds it |
| `@launcher_picker_key` | none | Prefix key that opens an fzf app picker in a popup |
| `@launcher_marker` | none | Marker file or directory used by every app without its own marker |
| `@launcher_max_depth` | `20` | Number of parent directories the marker search climbs |
| `@launcher_skip_missing` | off | `on` binds no direct key for an app whose command is not on `PATH`; apps with a host are not checked |

### Per-app options

| Option | Default | Meaning |
|:-------|:--------|:--------|
| `@launcher_<id>_key` | none | Prefix key for this app; no key is bound until you set one |
| `@launcher_<id>_command` | the id | Shell command to run |
| `@launcher_<id>_mode` | `popup`, `window` for `yazi` | `popup`, `window` or `split` |
| `@launcher_<id>_name` | the id | Window name in `window` mode and label in the menu |
| `@launcher_<id>_width` | `80%` | Popup width |
| `@launcher_<id>_height` | `80%` | Popup height |
| `@launcher_<id>_marker` | none | Walk up from the pane directory to the one holding this marker, such as `.git`; falls back to the pane directory |
| `@launcher_<id>_if` | none | Shell predicate run before launch; a non-zero exit cancels it. `LAUNCHER_PATH` holds the start directory |
| `@launcher_<id>_prompt` | none | Prompt text; each typed word is appended to the command as a quoted argument |
| `@launcher_<id>_group` | none | Space-separated app ids opened in one new window and tiled |
| `@launcher_<id>_host` | none | Remote host; the composed command runs under `ssh -t` |
| `@launcher_<id>_reuse` | off | `on` in `window` mode selects a window with the same name instead of opening another |
| `@launcher_<id>_env` | none | Variables placed before the command with `env`, such as `FOO=bar` |
| `@launcher_<id>_pre` | none | Command run first; the app starts only if it succeeds |
| `@launcher_<id>_exit` | none | Command run after the app exits |

### Internal state

The plugin writes these options itself. Do not set them.

| Option | Holds |
|:-------|:------|
| `@launcher_prompt_value` | The text typed at an app's prompt, read once by the launch |
| `@launcher_picked` | The app chosen in the fzf picker, cleared when it launches |

## Key bindings

| Key | Action | Default |
|:----|:-------|:--------|
| `prefix + M-a` | Menu of every app in `@launcher_apps` | Bound |
| `@launcher_<id>_key` | Launch that app | Unbound |
| `@launcher_picker_key` | fzf app picker | Unbound |

Version 2.0.0 removed the old direct keys. To restore them:

```tmux
set -g @launcher_lazygit_key 'C-g'
set -g @launcher_yazi_key 'C-y'
```

## How it works

[`launcher-revamped.tmux`](launcher-revamped.tmux) runs [`src/launcher.sh`](src/launcher.sh) once when tmux loads the plugin. That script reads the options and binds the menu, the picker and each app key. Every binding calls the same script back with `dispatch <id>` through `run-shell -b`, so the work happens when you press the key.

At launch, `dispatch` resolves the start directory, runs the `_if` predicate, and builds the command in this order: `pre &&`, `env` variables, the command and its prompt arguments, then `; exit`. A host wraps the whole result in `ssh -t`. The mode decides between `display-popup -E`, `new-window` and `split-window`. On tmux older than 3.2, which has no `display-popup`, a popup app opens as a window.

The fzf picker runs inside `display-popup -E`, stores the chosen id in `@launcher_picked`, and launches it after the popup closes. A popup app can then open its own popup.

The pure helpers live in [`src/lib/launcher/launcher.sh`](src/lib/launcher/launcher.sh). Setting `LAUNCHER_DRY_RUN` makes the script print each tmux call instead of running it, which is how the test suite checks the bindings.

## Development

| Command | What it does |
|:--------|:-------------|
| `make test` | Runs the bats suite |
| `make lint` | Runs shellcheck on every shell file |
| `make coverage` | Measures line coverage with kcov on Linux and fails below 95% |

Changes are listed in [CHANGELOG.md](CHANGELOG.md).

## License

[MIT](LICENSE)

<!-- family:begin -->

## The tmux-revamped family

This plugin is one member of the tmux-revamped family. Every member carries the
same contract in [`FAMILY.md`](FAMILY.md), the same tooling under `family/`, and
the same shared library, all held byte-identical by a checksum manifest. They are
built to be installed together: no member claims a key or a tmux option that
another member claims.

A defect found in one member is hunted across all of them before the fix is
called done. That obligation is written into the contract rather than left to
memory, and `family/bin/sweep` is how it is discharged.

| Member | What it does |
|---|---|
| [`tmux-autoreload-revamped`](https://github.com/tmux-revamped/tmux-autoreload-revamped) | Edit your tmux config, save, and watch it reload itself, no key, no command |
| [`tmux-battery-revamped`](https://github.com/tmux-revamped/tmux-battery-revamped) | Battery status for your tmux status bar, without ever blocking the status render |
| [`tmux-bluetooth-revamped`](https://github.com/tmux-revamped/tmux-bluetooth-revamped) | Every connected Bluetooth device and its battery in your tmux status bar, without blocking the render |
| [`tmux-cpu-revamped`](https://github.com/tmux-revamped/tmux-cpu-revamped) | CPU load, temperature, and frequency in your tmux status bar, without ever blocking the render |
| [`tmux-disk-revamped`](https://github.com/tmux-revamped/tmux-disk-revamped) | Disk usage for your tmux status bar, without ever blocking the status render |
| [`tmux-extract-revamped`](https://github.com/tmux-revamped/tmux-extract-revamped) | Pick a URL, path, hash or any other token off the screen with fzf and type it at the cursor, in pure shell |
| [`tmux-fzf-revamped`](https://github.com/tmux-revamped/tmux-fzf-revamped) | Switch to, kill, rename or create tmux sessions, windows and panes from fzf pickers in a popup |
| [`tmux-git-revamped`](https://github.com/tmux-revamped/tmux-git-revamped) | Show the active pane's git branch, changes and provider counts in the tmux status bar without blocking it |
| [`tmux-gpu-revamped`](https://github.com/tmux-revamped/tmux-gpu-revamped) | GPU load, temperature, clock, power and memory in the tmux status bar, from NVIDIA, AMD, Intel and Apple GPUs |
| [`tmux-kube-revamped`](https://github.com/tmux-revamped/tmux-kube-revamped) | Current Kubernetes context and namespace in the tmux status bar, parsed from kubeconfig without kubectl |
| [`tmux-launcher-revamped`](https://github.com/tmux-revamped/tmux-launcher-revamped) | **this plugin**, Launch any TUI app in a popup or a window, scoped to the current pane's directory, with one configurable bindi |
| [`tmux-logging-revamped`](https://github.com/tmux-revamped/tmux-logging-revamped) | Capture any pane to a file: live logging, full scrollback, or a one-shot screenshot |
| [`tmux-music-revamped`](https://github.com/tmux-revamped/tmux-music-revamped) | Now playing in your tmux status bar, without ever blocking the status render |
| [`tmux-network-revamped`](https://github.com/tmux-revamped/tmux-network-revamped) | Network throughput in your tmux status bar, without ever blocking the render |
| [`tmux-pain-control-revamped`](https://github.com/tmux-revamped/tmux-pain-control-revamped) | Pane and window management bindings for tmux, version aware, vim friendly, every prefix key can be disabled |
| [`tmux-persist-revamped`](https://github.com/tmux-revamped/tmux-persist-revamped) | Save every tmux session, window and pane, auto-save on a timer, and restore it all after a reboot |
| [`tmux-plugin-template`](https://github.com/tmux-revamped/tmux-plugin-template) | The starting point for a tmux-revamped plugin: shared library, bats harness, CI and family tooling |
| [`tmux-pomodoro-revamped`](https://github.com/tmux-revamped/tmux-pomodoro-revamped) | A Pomodoro timer in the tmux status bar that keeps all of its state in tmux options, with no temp files |
| [`tmux-ram-revamped`](https://github.com/tmux-revamped/tmux-ram-revamped) | RAM, swap and memory pressure in the tmux status bar, sampled in the background so the render never waits |
| [`tmux-reorder-revamped`](https://github.com/tmux-revamped/tmux-reorder-revamped) | Drag a window tab along the tmux status bar with the mouse to move that window |
| [`tmux-scroll-revamped`](https://github.com/tmux-revamped/tmux-scroll-revamped) | Send the mouse wheel to apps that scroll themselves and into tmux copy-mode everywhere else |
| [`tmux-sensible-revamped`](https://github.com/tmux-revamped/tmux-sensible-revamped) | Sensible tmux defaults, gated by tmux version and terminal, that leave the options you set alone |
| [`tmux-tiling-revamped`](https://github.com/tmux-revamped/tmux-tiling-revamped) | Tiling window management for tmux: eight layouts including BSP dwindle and spiral, with layout undo |
| [`tmux-time-revamped`](https://github.com/tmux-revamped/tmux-time-revamped) | Local and world clocks for the tmux status bar, colored by time of day, with countdowns and a DST warning |
| [`tmux-weather-revamped`](https://github.com/tmux-revamped/tmux-weather-revamped) | Weather for the tmux status bar from wttr.in, fetched in the background so the status line never waits |

### Checking an installation

With every member on disk, one command reports any conflict between them:

```sh
family/bin/doctor --live
```

It reads each member and the running tmux server, and reports duplicate keys,
duplicate status placeholders, options outside the naming grammar, and any
member whose contract version has fallen behind.

<!-- family:end -->
