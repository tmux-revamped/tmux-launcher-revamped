<div align="center">

# tmux-launcher-revamped

<strong>Open any terminal app in a tmux popup, window or split from one menu, starting at the project root.</strong>

English &nbsp;|&nbsp; [日本語](README.ja.md) &nbsp;|&nbsp; [简体中文](README.zh-Hans.md) &nbsp;|&nbsp; [繁體中文（香港）](README.zh-HK.md)

[![ci](https://img.shields.io/github/actions/workflow/status/tmux-revamped/tmux-launcher-revamped/ci.yml?branch=main&style=flat-square&label=ci)](https://github.com/tmux-revamped/tmux-launcher-revamped/actions/workflows/ci.yml)
[![release](https://img.shields.io/github/v/release/tmux-revamped/tmux-launcher-revamped?style=flat-square&label=release)](https://github.com/tmux-revamped/tmux-launcher-revamped/releases/latest)
[![openssf scorecard](https://img.shields.io/ossf-scorecard/github.com/tmux-revamped/tmux-launcher-revamped?style=flat-square&label=openssf%20scorecard)](https://scorecard.dev/viewer/?uri=github.com/tmux-revamped/tmux-launcher-revamped)
[![license](https://img.shields.io/github/license/tmux-revamped/tmux-launcher-revamped?style=flat-square&label=license)](LICENSE)

<p align="center">
  <a href="#quick-start"><strong>Quick start</strong></a> &nbsp;|&nbsp;
  <a href="#usage">Usage</a> &nbsp;|&nbsp;
  <a href="#apps">Apps</a> &nbsp;|&nbsp;
  <a href="#screens">Screens</a>
</p>

</div>

<p align="center">
  <img src="screens/hero.gif" alt="prefix M-a opens the launcher menu and tig opens in a popup at the project root" width="800">
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

You list the apps you use, such as lazygit, yazi, htop or k9s. `prefix M-a` opens a menu of all of them, and any app can have a key of its own. Each one opens in a popup, a window or a split, in the pane's folder or at the project root above it.

---

## Quick start

### Prerequisites

| Tool | Version | Used for |
|:-----|:--------|:---------|
| tmux | 3.2 or later | the family floor; a popup app opens as a window on an older tmux |
| fzf | any | the app picker, only when `@launcher_revamped_picker_key` is set |
| gum | optional | the menu, tables and colours of `launcher-revamped`; without it every command prints plain text |

The apps themselves must be installed; the plugin runs whatever command you give it.

### Install

```tmux
set -g @plugin 'tmux-revamped/tmux-launcher-revamped'
```

Then press `prefix + I`. Without TPM, clone the repository and run its entry point from `~/.tmux.conf`:

```bash
git clone https://github.com/tmux-revamped/tmux-launcher-revamped ~/.tmux/plugins/tmux-launcher-revamped
```

```tmux
run-shell ~/.tmux/plugins/tmux-launcher-revamped/launcher-revamped.tmux
```

`make install` in the clone also puts `launcher-revamped` in `~/.local/bin`, with its man page and completions under `~/.local/share`.

### Verify

```bash
~/.tmux/plugins/tmux-launcher-revamped/bin/launcher-revamped doctor
```

## Usage

Press `prefix M-a`. The menu lists every app in `@launcher_revamped_apps`, which defaults to lazygit in a popup and yazi in a window. A menu key you bound before the plugin loaded stays yours, and `doctor` says so.

| Command | What it does |
|:--------|:-------------|
| `launcher-revamped apply` | Binds every key now; the entry point runs it when tmux loads the plugin |
| `launcher-revamped list` | Prints every binding apply would make; `--json` prints one object |
| `launcher-revamped launch ID [ARG...]` | Opens the app `ID`; each word after it becomes one quoted argument |
| `launcher-revamped pick` | Chooses an app with fzf and records it for `launch-picked` |
| `launcher-revamped launch-picked` | Opens the app `pick` recorded |
| `launcher-revamped doctor` | One row per dependency, one per app, and the menu key when you had bound it first |
| `launcher-revamped version` | The version, then the tmux version |
| `launcher-revamped help` | The help page; `man launcher-revamped` documents the same commands and settings |
| `launcher-revamped` | On a terminal, a menu |

| tmux option | Default | Meaning |
|:------------|:--------|:--------|
| `@launcher_revamped_apps` | `lazygit yazi` | The app IDs the menu lists |
| `@launcher_revamped_menu_key` | `M-a` | The prefix key for the menu; `off` or `none` binds no menu |
| `@launcher_revamped_picker_key` | none | The prefix key for the fzf app picker |
| `@launcher_revamped_marker` | none | A file or folder, such as `.git`, that marks the project root for every app without its own |
| `@launcher_revamped_max_depth` | `20` | How many folders the marker search climbs |
| `@launcher_revamped_skip_missing` | `off` | `on` binds no key for an app whose command is not installed; an app with a host is not checked |

Every option is also a command option with dashes, such as `--menu-key M-o`, and an environment variable, such as `LAUNCHER_REVAMPED_MENU_KEY`; the command line wins over the environment, and the environment over the tmux option. A setting given as a tmux option is read when an app launches, and one given to `launcher-revamped apply` on the command line or in the environment rides on the keys it binds. An empty tmux option means its default.

The options were named `@launcher_*` before 3.0.0, and those names no longer work.

<a id="apps"></a>

## Apps

Each ID in `@launcher_revamped_apps` reads its own options, `@launcher_revamped_<id>_<field>`:

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

| Field | Default | Meaning |
|:------|:--------|:--------|
| `_key` | none | The app's own prefix key |
| `_command` | the ID | What it runs |
| `_mode` | `popup`, `window` for yazi | `popup`, `window` or `split`; a popup needs tmux 3.2 |
| `_name` | the ID | The window name and the menu label |
| `_width`, `_height` | `80%` | The popup size |
| `_marker` | none | Its own project marker |
| `_if` | none | A shell check run first; a non-zero exit keeps the app closed, and `LAUNCHER_PATH` holds the folder it would start in |
| `_prompt` | none | A prompt shown first; each typed word becomes a quoted argument |
| `_group` | none | App IDs opened in one new window, tiled |
| `_host` | none | A host it runs on through `ssh -t` |
| `_reuse` | `off` | `on` selects its window when one with its name is open |
| `_env` | none | Variables set before the command, such as `A=1` |
| `_pre` | none | A command that must succeed first |
| `_exit` | none | A command run after it exits |

File managers with image previews, such as yazi, lf and ranger, work better in `window` mode: tmux popups do not pass image escape sequences through.

The command is built as `pre && env VARS command ARGS; exit`, and a host wraps all of it in `ssh -t`. The picker runs inside a popup and records the chosen ID in `@launcher_revamped_picked`; `launch-picked` opens it after the popup closes, so a popup app can open its own popup.

<a id="screens"></a>

## Screens

<details>
<summary>Every screen, recorded inside a real tmux with <code>make screens</code>, with each key on the status line</summary>
<br>

<table>
<tr>
<td width="50%" valign="top"><img src="screens/menu.png" alt="launcher-revamped: The menu of every app on prefix M-a"><br><sub>The menu of every app on prefix M-a, from <code>apps.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/popup.png" alt="launcher-revamped: tig in a popup at the project root"><br><sub>tig in a popup at the project root, from <code>apps.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/window.png" alt="launcher-revamped: vim in a window of its own"><br><sub>vim in a window of its own, from <code>apps.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/split.png" alt="launcher-revamped: A split beside the work"><br><sub>A split beside the work, from <code>apps.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/prompt.png" alt="launcher-revamped: A prompt whose words become arguments"><br><sub>A prompt whose words become arguments, from <code>apps.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/picker.png" alt="launcher-revamped: The fzf app picker"><br><sub>The fzf app picker, from <code>apps.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/group.png" alt="launcher-revamped: A group of apps tiled in one window"><br><sub>A group of apps tiled in one window, from <code>apps.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/list.png" alt="launcher-revamped: list"><br><sub><code>list</code>, from <code>stills.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/json.png" alt="launcher-revamped: list --json"><br><sub><code>list --json</code>, from <code>stills.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/doctor.png" alt="launcher-revamped: doctor"><br><sub><code>doctor</code>, from <code>stills.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/plain-menu.png" alt="launcher-revamped: The menu without gum"><br><sub>The menu without gum, from <code>stills.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/plain-apply.png" alt="launcher-revamped: apply from the menu"><br><sub><code>apply</code> from the menu, from <code>stills.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/version.png" alt="launcher-revamped: The version"><br><sub>The version, from <code>stills.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/error.png" alt="launcher-revamped: An unknown command"><br><sub>An unknown command, from <code>stills.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/themes.png" alt="launcher-revamped: The header in six themes"><br><sub>The header in six themes, from <code>themes.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/help.png" alt="launcher-revamped: The help page"><br><sub>The help page, from <code>help.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/accent.png" alt="launcher-revamped: An accent from LAUNCHER_REVAMPED_ACCENT"><br><sub>An accent from <code>LAUNCHER_REVAMPED_ACCENT</code>, from <code>stills.tape</code></sub></td>
<td width="50%" valign="top"></td>
</tr>
</table>

</details>

## Portability

The plugin is POSIX `sh`. CI runs every suite on each row below.

| Shell | Status |
|:------|:-------|
| `dash`, `/bin/sh` on macOS | Supported |
| `bash` 3.2 and 5.x, the system's `zsh` and Homebrew's | Supported |

| System | Status |
|:-------|:-------|
| macOS | Tahoe on Apple Silicon and Intel, with the tools it ships, Homebrew's GNU tools and Homebrew's uutils |
| Linux | Ubuntu 26.04 on x86_64 and arm64, with GNU coreutils, uutils and BusyBox |

## Development

| Command | What it runs |
|:--------|:-------------|
| `make fmt` | shfmt `-i 2` on every script |
| `make lint` | shfmt, ShellCheck, mandoc, yamllint and actionlint, at zero findings |
| `make test` | The bats suites under the system `sh` |
| `make test-all` | The suites under every installed shell, both builds of bash and zsh on macOS |
| `make test-linux` | The suites in an Ubuntu container |
| `make coverage` | bashcov on this Mac and in the Ubuntu container, merged and gated at 100 percent |
| `make screens` | The screens above, recorded from the real plugin inside tmux with VHS, on macOS |
| `make install` | The command, its man page and completions under `PREFIX` |

On macOS, `brew bundle` installs every tool these targets call, from the [`Brewfile`](Brewfile).

Commits follow the conventional commit format and go straight to `main`. After a green `ci` run on `main`, `release.yml` runs semantic-release: every `feat` or `fix` since the last tag publishes a release, stamps the version constant and adds the notes to [`CHANGELOG.md`](CHANGELOG.md).

## License

[MIT](LICENSE), copyright Gustavo Franco.

<!-- family:begin -->

## The tmux-revamped family

This plugin is one member of the tmux-revamped family. Every member carries the same contract in [`FAMILY.md`](FAMILY.md) and the same shared library, and they are built to be installed together: no member claims a key or a tmux option that another member claims.

A defect found in one member is hunted across all of them before the fix is called done.

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
| [`tmux-launcher-revamped`](https://github.com/tmux-revamped/tmux-launcher-revamped) | **this plugin**, Open any terminal app in a tmux popup, window or split from one menu, starting at the project root |
| [`tmux-logging-revamped`](https://github.com/tmux-revamped/tmux-logging-revamped) | Capture any pane to a file: live logging, full scrollback, or a one-shot screenshot |
| [`tmux-music-revamped`](https://github.com/tmux-revamped/tmux-music-revamped) | Now playing in your tmux status bar, without ever blocking the status render |
| [`tmux-network-revamped`](https://github.com/tmux-revamped/tmux-network-revamped) | Network throughput in your tmux status bar, without ever blocking the render |
| [`tmux-pain-control-revamped`](https://github.com/tmux-revamped/tmux-pain-control-revamped) | Pane and window management bindings for tmux, version aware, vim friendly, every prefix key can be disabled |
| [`tmux-persist-revamped`](https://github.com/tmux-revamped/tmux-persist-revamped) | Save every tmux session, window and pane, auto-save on a timer, and restore it all after a reboot |
| [`tmux-plugin-template`](https://github.com/tmux-revamped/tmux-plugin-template) | The starting point for a tmux-revamped plugin: shared library, bats harness and CI |
| [`tmux-pomodoro-revamped`](https://github.com/tmux-revamped/tmux-pomodoro-revamped) | A Pomodoro timer in the tmux status bar that keeps all of its state in tmux options, with no temp files |
| [`tmux-ram-revamped`](https://github.com/tmux-revamped/tmux-ram-revamped) | RAM, swap and memory pressure in the tmux status bar, sampled in the background so the render never waits |
| [`tmux-reorder-revamped`](https://github.com/tmux-revamped/tmux-reorder-revamped) | Drag a window tab along the tmux status bar with the mouse to move that window |
| [`tmux-scroll-revamped`](https://github.com/tmux-revamped/tmux-scroll-revamped) | Send the mouse wheel to apps that scroll themselves and into tmux copy-mode everywhere else |
| [`tmux-sensible-revamped`](https://github.com/tmux-revamped/tmux-sensible-revamped) | Sensible tmux defaults, gated by tmux version and terminal, that leave the options you set alone |
| [`tmux-tiling-revamped`](https://github.com/tmux-revamped/tmux-tiling-revamped) | Tiling window management for tmux: eight layouts including BSP dwindle and spiral, with layout undo |
| [`tmux-time-revamped`](https://github.com/tmux-revamped/tmux-time-revamped) | Local and world clocks for the tmux status bar, colored by time of day, with countdowns and a DST warning |
| [`tmux-weather-revamped`](https://github.com/tmux-revamped/tmux-weather-revamped) | Weather for the tmux status bar from wttr.in, fetched in the background so the status line never waits |

<!-- family:end -->
