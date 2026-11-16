# tmux-launcher-revamped

Guidance for anyone, human or agent, changing tmux-launcher-revamped. What it is and how to use it lives in [README.md](README.md).

[FAMILY.md](FAMILY.md) holds everything this plugin shares with the rest of the tmux-revamped family, and it is the same in every member. This file holds only what is exclusive to tmux-launcher-revamped, under the same headings as the agent guide of every member. Read both before changing anything; a rule that would serve the other members goes into [`FAMILY.md`](FAMILY.md) instead of here.

## Layout

| Path | Holds |
|:-----|:------|
| [`launcher-revamped.tmux`](launcher-revamped.tmux) | The entry point TPM runs: it runs `bin/launcher-revamped apply` |
| [`bin/launcher-revamped`](bin/launcher-revamped) | The command: `apply`, `list`, `launch`, `pick`, `launch-picked`, `doctor`, `version`, `help` and the menu. `apply`, `launch`, `pick` and `launch-picked` run without loading the interface modules |
| [`lib/launcher.sh`](lib/launcher.sh) | Reading the settings, the version checks and the binding plan |
| [`lib/launch.sh`](lib/launch.sh) | Opening an app: the marker search, the command, the mode, groups and the picker |
| [`lib/state.sh`](lib/state.sh) | Every global, including `LAUNCHER_REVAMPED_GLOBALS` and `LAUNCHER_REVAMPED_FIELDS`, the tables of setting names and defaults the rest reads |
| [`lib/core.sh`](lib/core.sh) | The version |
| [`lib/`](lib) | Every other file is the shared library, identical in every member |
| [`test/launcher.bats`](test/launcher.bats), [`test/launch.bats`](test/launch.bats), [`test/commands.bats`](test/commands.bats), [`test/entrypoint.bats`](test/entrypoint.bats) | This member's suites: the plan, opening apps through the tmux stub, the commands, and the entry point and launches on a private tmux server |
| [`screens/`](screens) | The tapes and the recording's tmux config. `prepare.sh` copies the plugin to the demo folder, so no still shows a checkout path, and builds a demo git project; the config gives every pane the demo home, UTC and no fzf options of the person recording |

## Names

- Global settings are the tmux options `@launcher_revamped_apps`, `_menu_key`, `_picker_key`, `_marker`, `_max_depth` and `_skip_missing`. Each app ID reads `@launcher_revamped_<id>_<field>` for the fields in `LAUNCHER_REVAMPED_FIELDS`. Every one is also a long option with dashes, such as `--lazygit-key`, and an environment variable, such as `LAUNCHER_REVAMPED_LAZYGIT_KEY`.
- The plugin writes `@launcher_revamped_typed`, the text typed at an app's prompt, and `@launcher_revamped_picked`, the ID the picker chose.
- It has no status placeholders.
- The version constant is `LAUNCHER_REVAMPED_VERSION`.

## Behaviour

- `apply` reads the globals and every app's fields with two `tmux display-message` calls and one `env` read, reads `list-keys` once for the menu key, builds the plan, and sends every binding to tmux in one call separated by `;`.
- `launch` reads the globals, the app's fields and the pane's folder with one `tmux display-message` call. Every launch binding passes `TMUX_PANE=#{pane_id}`, which tmux expands for the pane the key was pressed in, and `launch` targets that pane; run from a shell, it targets the shell's own pane through the same variable. A group reads its members' fields with one more and opens them in one call.
- An empty tmux option means its default; an empty environment variable or long option leaves that key unbound.
- The plan holds one argument per line and a blank line between commands; an empty argument, the menu items' shortcut key, is written as `''` and sent to tmux as an empty string.
- A menu key the person bound before the plugin loaded stays theirs, and `doctor` reports it.
- The entry point clears every inherited `REVAMPED_` variable except the test switches, and every `LAUNCHER_REVAMPED_*_LOADED` guard; every other global is assigned outright in the state file.

## Domain rules

- A popup needs tmux 3.2; on an older tmux a popup app opens as a window. Notes on the bindings need tmux 3.1.
- The marker search climbs from the pane's folder until it finds the marker, reaches the root or has climbed `max_depth` folders, and falls back to the pane's folder.
- The command is `pre && env VARS command ARGS; exit`, and a host wraps all of it, quoted, in `ssh -t`. Each typed or passed word becomes one single-quoted argument.
- The picker runs inside `display-popup -E` and only records its choice, so `launch-picked` opens the app after the popup closes and a popup app can open its own popup.

## Release

- `LAUNCHER_REVAMPED_VERSION` in [`lib/core.sh`](lib/core.sh) holds the version. Nobody edits it by hand.
- After a green `ci` run on `main`, [`release.yml`](.github/workflows/release.yml) runs semantic-release: a `feat` or `fix` since the last tag publishes a release, [`set-version.sh`](.github/scripts/set-version.sh) stamps the constant, and the notes go into [`CHANGELOG.md`](CHANGELOG.md).

## Gaps against FAMILY.md

As of 2026-11-16, none.
