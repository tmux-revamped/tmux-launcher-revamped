#!/usr/bin/env bats
# shellcheck disable=SC2016,SC2030,SC2031,SC2034

# shellcheck source=test/helpers.bash
source "${BATS_TEST_DIRNAME:-.}/helpers.bash"

bats_require_minimum_version 1.5.0

setup() {
  harness_setup
  for name in $(compgen -v LAUNCHER_REVAMPED_); do
    unset "${name}"
  done
  export REVAMPED_TEST_TMUX_ARGV="${BATS_TEST_TMPDIR}/argv"
  : >"${REVAMPED_TEST_TMUX_ARGV}"
}

option() {
  printf '%s' "$2" >"${REVAMPED_TEST_TMUX_DIR}/$(printf '%s' "g.-.@launcher_revamped_$1" | tr -c 'A-Za-z0-9_.-' '_')"
}

tool() {
  # shellcheck disable=SC2086
  run --separate-stderr ${REVAMPED_TEST_SHELL:-sh} "${REVAMPED_TESTS_DIR}/../bin/launcher-revamped" "$@"
}

opened() {
  grep -E '^(display-popup|new-window|split-window|select-window)' "${REVAMPED_TEST_TMUX_ARGV}"
}

fake_fzf() {
  mkdir -p "${BATS_TEST_TMPDIR}/stubs"
  printf '#!/bin/sh\n%s\n' "$1" >"${BATS_TEST_TMPDIR}/stubs/fzf"
  chmod +x "${BATS_TEST_TMPDIR}/stubs/fzf"
}

@test "launch - lazygit opens a popup at the pane's folder by default" {
  # Arrange
  export REVAMPED_TEST_TMUX_VERSION=3.6

  # Act
  tool launch lazygit

  # Assert
  [[ "${status}" -eq 0 ]]
  run opened
  [[ "${output}" == "display-popup|-E|-w|80%|-h|80%|-d|#{pane_current_path}|lazygit" ]]
}

@test "launch - a popup opens as a window before tmux 3.2" {
  # Arrange
  export REVAMPED_TEST_TMUX_VERSION=3.1

  # Act
  tool launch lazygit

  # Assert
  run opened
  [[ "${output}" == "new-window|-n|lazygit|-c|#{pane_current_path}|lazygit" ]]
}

@test "launch - yazi opens a window by default" {
  # Arrange
  local app=yazi

  # Act
  tool launch "${app}"

  # Assert
  run opened
  [[ "${output}" == "new-window|-n|yazi|-c|#{pane_current_path}|yazi" ]]
}

@test "launch - an unknown mode opens a window" {
  # Arrange
  option btop_mode floating

  # Act
  tool launch btop

  # Assert
  run opened
  [[ "${output}" == "new-window|-n|btop|-c|#{pane_current_path}|btop" ]]
}

@test "launch - the popup size, env, pre and exit hooks shape the command" {
  # Arrange
  option lazygit_width 60%
  option lazygit_height 40%
  option lazygit_env 'A=1 B=2'
  option lazygit_pre 'git fetch'
  option lazygit_exit 'tmux refresh-client -S'

  # Act
  tool launch lazygit

  # Assert
  run opened
  [[ "${output}" == "display-popup|-E|-w|60%|-h|40%|-d|#{pane_current_path}|git fetch && env A=1 B=2 lazygit; tmux refresh-client -S" ]]
}

@test "launch - a host runs the whole command over ssh -t" {
  # Arrange
  option k9s_host "box's"
  option k9s_mode split
  option k9s_pre 'cd /srv'

  # Act
  tool launch k9s

  # Assert
  run opened
  [[ "${output}" == "split-window|-c|#{pane_current_path}|ssh -t 'box'\\''s' 'cd /srv && k9s'" ]]
}

@test "launch - every word after the app becomes one quoted argument" {
  # Arrange
  option man_mode split

  # Act
  tool launch man "printf  3" "it's"

  # Assert
  run opened
  [[ "${output}" == "split-window|-c|#{pane_current_path}|man 'printf' '3' 'it'\\''s'" ]]
}

@test "launch - an app with an empty command opens nothing" {
  # Arrange
  export LAUNCHER_REVAMPED_GHOST_COMMAND=''

  # Act
  tool launch ghost

  # Assert
  [[ "${status}" -eq 0 ]]
  run opened
  [[ -z "${output}" ]]
}

@test "launch - without an app it is a usage error" {
  # Arrange
  local command=launch

  # Act
  tool "${command}"

  # Assert
  [[ "${status}" -eq 1 ]]
  [[ "${stderr}" == "launcher-revamped: no app given. run 'launcher-revamped help' for usage." ]]
}

@test "launch - the marker search finds the nearest folder that holds it" {
  # Arrange
  local root="${BATS_TEST_TMPDIR}/proj"
  mkdir -p "${root}/a/b/.git" "${root}/.git" "${root}/a/b/c/d"
  export PROBE_START="${root}/a/b/c/d"

  # Act
  lib_run launch 'launcher_revamped_walk "${PROBE_START}" .git 20'

  # Assert
  [[ "${output}" == "${BATS_TEST_TMPDIR}/proj/a/b" ]]
}

@test "launch - the marker search stops at its depth and falls back to the start" {
  # Arrange
  local root="${BATS_TEST_TMPDIR}/proj"
  mkdir -p "${root}/.git" "${root}/a/b"
  export PROBE_START="${root}/a/b"

  # Act
  lib_run launch 'launcher_revamped_walk "${PROBE_START}" .git 2; printf "|"; launcher_revamped_walk "${PROBE_START}" .git 3'

  # Assert
  [[ "${output}" == "${BATS_TEST_TMPDIR}/proj/a/b|${BATS_TEST_TMPDIR}/proj" ]]
}

@test "launch - the marker search climbs to the root and a bad depth means 20" {
  # Arrange
  local marker=launcher-revamped-no-such-marker

  # Act
  lib_run launch "launcher_revamped_walk /usr/bin ${marker} x; printf '|'; launcher_revamped_walk /usr/bin ${marker} ''"

  # Assert
  [[ "${output}" == "/usr/bin|/usr/bin" ]]
}

@test "launch - a global marker scopes an app without its own" {
  # Arrange
  local root="${BATS_TEST_TMPDIR}/proj"
  mkdir -p "${root}/.hg" "${root}/x"
  option marker .hg
  export PROBE_START="${root}/x"

  # Act
  lib_run launch 'launcher_revamped_load "${LAUNCHER_REVAMPED_GLOBALS}"; LAUNCHER_REVAMPED_PATH="${PROBE_START}"; launcher_revamped_scope lazygit'

  # Assert
  [[ "${output}" == "${BATS_TEST_TMPDIR}/proj" ]]
}

@test "pick - the chosen app is recorded for launch-picked" {
  # Arrange
  fake_fzf 'tail -n 1'
  option apps 'lazygit yazi htop'

  # Act
  tool pick

  # Assert
  [[ "${status}" -eq 0 ]]
  run tmux_calls
  [[ "${output}" == *"set-option -gq @launcher_revamped_picked htop"* ]]
}

@test "pick - a cancelled picker records an empty pick" {
  # Arrange
  fake_fzf 'exit 130'

  # Act
  tool pick

  # Assert
  [[ "${status}" -eq 0 ]]
  run tmux_calls
  [[ "${output}" == *"set-option -gq @launcher_revamped_picked "* ]]
}

@test "pick - without fzf it fails and names the install" {
  # Arrange
  harness_hide fzf

  # Act
  tool pick

  # Assert
  [[ "${status}" -eq 1 ]]
  [[ "${stderr}" == "launcher-revamped: pick needs fzf. install it with: brew install fzf, or apt install fzf" ]]
}

@test "launch-picked - the recorded app is cleared and launched" {
  # Arrange
  option picked yazi

  # Act
  tool launch-picked

  # Assert
  [[ "${status}" -eq 0 ]]
  run tmux_calls
  [[ "${output}" == *"set-option -gqu @launcher_revamped_picked"* ]]
  run opened
  [[ "${output}" == "new-window|-n|yazi|-c|#{pane_current_path}|yazi" ]]
}

@test "launch-picked - no recorded app launches nothing" {
  # Arrange
  local command=launch-picked

  # Act
  tool "${command}"

  # Assert
  [[ "${status}" -eq 0 ]]
  run opened
  [[ -z "${output}" ]]
}
