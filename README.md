<div align="center">

<h1>tmux-launcher-revamped</h1>

**Launch any TUI app in a popup or a window, scoped to the current pane's directory, with one configurable binding per app.**

[![Tests](https://github.com/tmux-revamped/tmux-launcher-revamped/actions/workflows/tests.yml/badge.svg)](https://github.com/tmux-revamped/tmux-launcher-revamped/actions/workflows/tests.yml) [![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE) [![Version](https://img.shields.io/badge/version-1.1.0-blue.svg)](CHANGELOG.md)

</div>

**any** app · **popup, window, or split** · **tmux 1.9 to 3.5** · **83** tests · **95%+** coverage

Bind a key to open `lazygit`, `yazi`, `lf`, `htop`, `k9s`, or any other terminal app, in a floating popup or a fresh window, always starting in the current pane's directory. You list the apps and set a key, command, mode, and size for each. Popups need tmux 3.2, so on older tmux a popup launcher falls back to a window automatically.

Built from [tmux-plugin-template](https://github.com/tmux-revamped/tmux-plugin-template).

<table>
<tr>
<td><strong>Any app</strong><br>Define `name`, key, command, and mode for each launcher; nothing is hardcoded.</td>
<td><strong>Popup or window</strong><br>Pick a floating popup or a real window per app. Apps that need image passthrough work in a window.</td>
</tr>
<tr>
<td><strong>Current directory</strong><br>Every launcher starts in `#{pane_current_path}`, so the app opens where you are.</td>
<td><strong>Version-aware</strong><br>`display-popup` is used on tmux 3.2 and up; below that, a popup launcher opens a window instead.</td>
</tr>
</table>

## How it works

List your apps in `@launcher_apps`. For each app `<id>`, set its options. `lazygit` (popup, `C-g`) and `yazi` (window, `C-y`) ship as working defaults.

```tmux
set -g @plugin 'tmux-revamped/tmux-launcher-revamped'

# add your own apps to the list
set -g @launcher_apps 'lazygit yazi lazydocker htop k9s'

set -g @launcher_lazydocker_key 'C-d'
set -g @launcher_htop_key 'C-t'
set -g @launcher_k9s_key 'C-s'
```

## Configuration

`@launcher_apps` is a space separated list of app ids. Each id reads the options below.

| Option | Default | Meaning |
|--------|---------|---------|
| `@launcher_apps` | `lazygit yazi` | the apps to bind |
| `@launcher_<id>_key` | built-in for `lazygit`/`yazi`, else required | the prefix key |
| `@launcher_<id>_command` | the id itself | the shell command to run |
| `@launcher_<id>_mode` | `popup` (`yazi` is `window`) | `popup`, `window`, or `split` |
| `@launcher_<id>_name` | the id itself | window name, in `window` mode |
| `@launcher_<id>_width` | `80%` | popup width |
| `@launcher_<id>_height` | `80%` | popup height |
| `@launcher_<id>_marker` | none | walk up to the dir holding this marker (e.g. `.git`); falls back to the pane path |
| `@launcher_<id>_if` | none | predicate run before launch; non-zero makes the key inert (`LAUNCHER_PATH` is exported) |
| `@launcher_<id>_prompt` | none | prompt text; the typed value is appended to the command |
| `@launcher_<id>_group` | none | space separated app ids opened together as a tiled dashboard |
| `@launcher_<id>_host` | none | remote host; the command is wrapped in `ssh -t` |
| `@launcher_<id>_reuse` | off | in window mode, select an existing window instead of duplicating |
| `@launcher_<id>_env` | none | env vars prefixed onto the command (e.g. `FOO=bar`) |
| `@launcher_<id>_pre` | none | command run before the app (e.g. `direnv allow`) |
| `@launcher_<id>_exit` | none | command run after the app exits (e.g. refresh a status line) |
| `@launcher_marker` | none | default marker for every app when no per-app marker is set |
| `@launcher_max_depth` | `20` | how many levels the marker walk climbs |
| `@launcher_skip_missing` | off | drop any app whose local command is absent (remote apps are not probed) |
| `@launcher_menu_key` | none | key that opens a `display-menu` of every app (works below tmux 3.2) |
| `@launcher_picker_key` | none | key that opens an fzf app picker in a popup |

An app listed without a key and without a built-in default is skipped, so a typo never produces a broken binding.

## More launch modes

Beyond a popup or window per app, each launcher can do more:

```tmux
# open lazygit only inside a git repo; a dead key does nothing
set -g @launcher_lazygit_if 'git -C "$LAUNCHER_PATH" rev-parse 2>/dev/null'

# scope to the project root, not the deep cwd
set -g @launcher_lazygit_marker '.git'

# a man-page launcher that prompts for the topic
set -g @launcher_man_key    'C-m'
set -g @launcher_man_prompt 'man:'

# a dashboard: lazygit, htop, and logs in one key
set -g @launcher_dash_key   'C-d'
set -g @launcher_dash_group 'lazygit htop logs'

# k9s against a remote box
set -g @launcher_k9s_key  'C-s'
set -g @launcher_k9s_host 'box.example'

# open beside your work instead of over it
set -g @launcher_htop_key  'C-t'
set -g @launcher_htop_mode 'split'

# refresh the git status segment after lazygit quits
set -g @launcher_lazygit_exit 'tmux refresh-client -S'

# one menu key listing every app, and an fzf picker
set -g @launcher_menu_key   'C-l'
set -g @launcher_picker_key 'C-p'

# drop apps whose command is not installed
set -g @launcher_skip_missing 'on'
```

The menu uses `display-menu`, which works on tmux below 3.2 where popups do not, so it stays a usable launcher on older tmux.

## Examples

Popular apps people bind, with the mode that works best. File and media tools with image previews want `window` mode, since tmux popups have no passthrough ([tmux#4329](https://github.com/tmux/tmux/issues/4329)).

| App | Command | Suggested mode | Why |
|-----|---------|----------------|-----|
| lazygit | `lazygit` | popup | quick git, no previews |
| lazydocker | `lazydocker` | popup | container TUI |
| gitui | `gitui` | popup | git TUI |
| k9s | `k9s` | popup | kubernetes TUI |
| htop / btop | `htop` / `btop` | popup | process monitor |
| gh dash | `gh dash` | popup | GitHub dashboard |
| taskwarrior-tui | `taskwarrior-tui` | popup | tasks |
| yazi | `yazi` | window | image previews need passthrough |
| lf | `lf` | window | file manager, previews |
| ranger | `ranger` | window | file manager, previews |
| nnn | `nnn` | window | file manager |
| broot | `broot` | window | directory tree, opens files |

A full block adding several of these:

```tmux
set -g @launcher_apps 'lazygit lazydocker k9s htop yazi lf'

set -g @launcher_lazydocker_key 'C-d'
set -g @launcher_k9s_key       'C-s'
set -g @launcher_htop_key      'C-t'
set -g @launcher_lf_key        'C-f'
set -g @launcher_lf_mode       'window'

# a roomier lazygit popup
set -g @launcher_lazygit_width  '90%'
set -g @launcher_lazygit_height '85%'
```

## Install

With [TPM](https://github.com/tmux-plugins/tpm), add to `~/.tmux.conf`:

```tmux
set -g @plugin 'tmux-revamped/tmux-launcher-revamped'
```

Then press `prefix + I` to install. Out of the box, `prefix + C-g` opens lazygit and `prefix + C-y` opens yazi.

Manual install:

```bash
git clone https://github.com/tmux-revamped/tmux-launcher-revamped ~/.tmux/plugins/tmux-launcher-revamped
run-shell ~/.tmux/plugins/tmux-launcher-revamped/launcher-revamped.tmux
```

## Compatibility

Works on every tmux version TPM supports, 1.9 and up, on Linux (x86_64 and arm64) and macOS (Intel and Apple Silicon). The `popup` mode uses `display-popup`, which is tmux 3.2 and up; on older tmux a popup launcher opens a window instead, so every binding still works. Each launcher runs whatever command you give it, so the app itself must be installed.

## Development

```bash
make test    # bats suite
make lint    # shellcheck
make coverage  # kcov line coverage on Linux
```

The decision logic lives in [`src/lib/launcher/launcher.sh`](src/lib/launcher/launcher.sh) as pure, seam-backed helpers, and the applier in [`src/launcher.sh`](src/launcher.sh) runs under a dry-run mode so the full binding matrix is validated without a live tmux.

## License

[MIT](LICENSE), copyright Gustavo Franco.

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
| [`tmux-extract-revamped`](https://github.com/tmux-revamped/tmux-extract-revamped) | Fuzzy-grab any URL, path, or word off the screen and paste it, pure shell, no Python |
| [`tmux-fzf-revamped`](https://github.com/tmux-revamped/tmux-fzf-revamped) | Jump to any session, window, or pane, or kill it, from one fzf popup |
| [`tmux-git-revamped`](https://github.com/tmux-revamped/tmux-git-revamped) | Git repository status in your tmux status bar, without ever blocking the render |
| [`tmux-gpu-revamped`](https://github.com/tmux-revamped/tmux-gpu-revamped) | GPU load, temperature, frequency, and memory for your tmux status bar |
| [`tmux-kube-revamped`](https://github.com/tmux-revamped/tmux-kube-revamped) | Current Kubernetes context and namespace in your tmux status bar, async, kubectl-free, never blocking |
| [`tmux-launcher-revamped`](https://github.com/tmux-revamped/tmux-launcher-revamped) | **this plugin**, Launch any TUI app in a popup or a window, scoped to the current pane's directory, with one configurable bindi |
| [`tmux-logging-revamped`](https://github.com/tmux-revamped/tmux-logging-revamped) | Capture any pane to a file: live logging, full scrollback, or a one-shot screenshot |
| [`tmux-music-revamped`](https://github.com/tmux-revamped/tmux-music-revamped) | Now playing in your tmux status bar, without ever blocking the status render |
| [`tmux-network-revamped`](https://github.com/tmux-revamped/tmux-network-revamped) | Network throughput in your tmux status bar, without ever blocking the render |
| [`tmux-pain-control-revamped`](https://github.com/tmux-revamped/tmux-pain-control-revamped) | Standard pane and window management bindings for tmux, version aware, vim friendly, and fully configurable |
| [`tmux-persist-revamped`](https://github.com/tmux-revamped/tmux-persist-revamped) | One plugin that captures every session, window, pane, layout, and working |
| [`tmux-plugin-template`](https://github.com/tmux-revamped/tmux-plugin-template) | A template for building non-blocking tmux status plugins |
| [`tmux-pomodoro-revamped`](https://github.com/tmux-revamped/tmux-pomodoro-revamped) | A Pomodoro timer in your tmux status bar, with zero temp files: all state lives in tmux options |
| [`tmux-ram-revamped`](https://github.com/tmux-revamped/tmux-ram-revamped) | RAM usage for your tmux status bar, without ever blocking the status render |
| [`tmux-scroll-revamped`](https://github.com/tmux-revamped/tmux-scroll-revamped) | Mouse wheel that does the right thing: scroll the app directly, copy-mode everywhere else. No app names to con |
| [`tmux-sensible-revamped`](https://github.com/tmux-revamped/tmux-sensible-revamped) | Sensible tmux defaults that normalize behavior across every tmux version, OS, and terminal, without clobbering |
| [`tmux-tiling-revamped`](https://github.com/tmux-revamped/tmux-tiling-revamped) | --- |
| [`tmux-time-revamped`](https://github.com/tmux-revamped/tmux-time-revamped) | Local clock and world clocks in your tmux status bar, without ever blocking the render |
| [`tmux-weather-revamped`](https://github.com/tmux-revamped/tmux-weather-revamped) | Weather in your tmux status bar, fetched in the background so the render never waits on the network |

### Checking an installation

With every member on disk, one command reports any conflict between them:

```sh
family/bin/doctor --live
```

It reads each member and the running tmux server, and reports duplicate keys,
duplicate status placeholders, options outside the naming grammar, and any
member whose contract version has fallen behind.

<!-- family:end -->
