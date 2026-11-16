# Changelog

# [3.0.0](https://github.com/tmux-revamped/tmux-launcher-revamped/compare/v2.0.0...v3.0.0) (2026-11-16)


* feat!: rewrite the plugin in POSIX sh ([29806d3](https://github.com/tmux-revamped/tmux-launcher-revamped/commit/29806d3074152f97c46b8102e022fa7a09801663))


### Bug Fixes

* **family:** fail when git cannot read a mode ([52896c8](https://github.com/tmux-revamped/tmux-launcher-revamped/commit/52896c84c1b41beb91b5183294078c95c4235ef9))
* **family:** honor only active exceptions ([f79ff15](https://github.com/tmux-revamped/tmux-launcher-revamped/commit/f79ff153059cf66926f4ca3cc136d074bb626b5d))
* **family:** reject unquoted replacements ([e1a81ad](https://github.com/tmux-revamped/tmux-launcher-revamped/commit/e1a81add4f21d5864970c3a3541916a3bc5a415d))
* **family:** require executable entry points ([dfc56c8](https://github.com/tmux-revamped/tmux-launcher-revamped/commit/dfc56c8959f12fd5397baff6ac1cae4283fef155))
* launch in the pane the key was pressed in ([4ee3580](https://github.com/tmux-revamped/tmux-launcher-revamped/commit/4ee3580f8c315efada4577a87dff67b1b1d9b40a))


### Features

* add a shared desktop notifier ([10124ef](https://github.com/tmux-revamped/tmux-launcher-revamped/commit/10124efe21ccf4331215417485539124c9189c3f))
* **family:** accept bot updates in the audit ([e78584e](https://github.com/tmux-revamped/tmux-launcher-revamped/commit/e78584e7bf1a9e95016b66d9b0d3bce2c48985aa))


### BREAKING CHANGES

* every option is renamed and the old names no longer
work. @launcher_<setting> becomes @launcher_revamped_<setting> for
apps, menu_key, picker_key, marker, max_depth and skip_missing, and
@launcher_<id>_<field> becomes @launcher_revamped_<id>_<field> for
every per-app field. The menu key's off value is none, where it was
off. The internal options are @launcher_revamped_typed and
@launcher_revamped_picked. LAUNCHER_DRY_RUN is gone; use
launcher-revamped list.

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [2.0.0] - 2026-10-17

### Changed

- **Breaking:** the app menu is now bound to `prefix + M-a` by default, the
  key the family allocates to this plugin; it was unbound before, and
  `@launcher_menu_key` set to `off` unbinds it. The built-in app keys are
  gone: lazygit `C-g` and yazi `C-y` are unbound by default. Set
  `@launcher_lazygit_key 'C-g'` and `@launcher_yazi_key 'C-y'` to restore
  them.

### Fixed

- Key, menu, and picker bindings quote the plugin path, so an install
  directory containing a space or a single quote launches correctly.
- The tmux version comparison no longer depends on `sort -V`, which some
  `sort` implementations lack.
- A prompt launcher appends every typed word to the command as a literal
  argument, instead of keeping only the first word and running shell
  metacharacters from the typed text.
- A remote launcher quotes the whole composed command for `ssh`, so its
  pre and exit hooks run on the remote host instead of locally.
- The fzf picker records the chosen app and dispatches it after its popup
  closes, so a popup app no longer tries to open inside the picker popup.

## [1.1.0] - 2026-06-30

### Added

- Global launcher menu: set `@launcher_menu_key` to open a `display-menu` listing
  every app. The menu works on tmux below 3.2, where popups are unavailable.
- Conditional launch guard: `@launcher_<id>_if` runs a predicate before dispatch.
  When it fails, the key does nothing instead of opening a dead launcher. The
  scoped path is exported as `LAUNCHER_PATH` for the predicate to test.
- Project-root scoping: `@launcher_<id>_marker` (or the global `@launcher_marker`)
  walks up from the pane path, bounded by `@launcher_max_depth`, and launches at
  the directory holding the marker, falling back to the pane path.
- Argument prompt passthrough: `@launcher_<id>_prompt` routes the key through
  `command-prompt`, appending the typed value to the command (man topic, ssh host).
- App-group launch: `@launcher_<id>_group` opens several apps as a tiled dashboard
  in one key.
- Split-pane mode: `@launcher_<id>_mode split` opens the app beside your work.
- Remote-host launch: `@launcher_<id>_host` wraps the command in `ssh -t` for a
  remote box.
- Reuse existing window: `@launcher_<id>_reuse on` selects a matching window in
  window mode instead of opening a duplicate.
- Missing-command skip: `@launcher_skip_missing on` drops any app whose local
  command is not on PATH (remote apps are never probed).
- Per-app env vars and pre/exit hooks: `@launcher_<id>_env`, `@launcher_<id>_pre`,
  and `@launcher_<id>_exit` compose around the command (direnv, status refresh).
- fzf app picker: set `@launcher_picker_key` to choose an app with fzf in a popup.

### Changed

- Each app key now routes through a single `dispatch` path, so every launch mode
  shares one code path. All launches and tmux calls go through one seam, which the
  dry-run test suite asserts without a live tmux, a popup, or a real app.

## [1.0.1] - 2026-06-23

### Changed

- Self-audit for the family hardening pass. The popup launcher binds, captures
  the chosen command, and runs it without leaving a stray pane. Being an action
  plugin, it emits no status colors, so the tmux 3.7 format-expansion change does
  not apply. No code change needed.

## [1.0.0] - 2026-06-21

### Added

- Launch any TUI app in a popup or a window, scoped to the current pane's path,
  configured per app via @launcher_apps and per-app key, command, mode, name,
  and popup size options.
- lazygit (popup) and yazi (window) ship as working defaults; yazi uses a window
  because tmux popups lack passthrough for image previews.
- Version gating: popup mode uses display-popup on tmux 3.2 and up and falls back
  to a window on older tmux, so every binding works from tmux 1.9 up.
