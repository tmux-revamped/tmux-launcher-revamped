#!/usr/bin/env bats
# shellcheck disable=SC2016,SC2030,SC2031,SC2034,SC2154

# shellcheck source=test/tmux_helpers.bash
source "${BATS_TEST_DIRNAME:-.}/tmux_helpers.bash"

bats_require_minimum_version 1.5.0

setup() {
  ROOT="$(cd "${BATS_TEST_DIRNAME}/.." && pwd)"
  setup_tmux_server
  tmux rename-window -t test main
  PROJECT="${BATS_TEST_TMPDIR}/project"
  mkdir -p "${PROJECT}/.git" "${PROJECT}/src"
}

teardown() {
  [[ -z "${HOST:-}" ]] || command tmux -S "${HOST}" kill-server 2>/dev/null || :
  [[ -z "${HOST:-}" ]] || rm -f "${HOST}"
  teardown_tmux_server
}

attach_host() {
  HOST="${TMUX_SOCKET}-host"
  command tmux -S "${HOST}" -f /dev/null new-session -d -s host -x 120 -y 30 \
    "env -u TMUX TERM=xterm-256color tmux -S '${TMUX_SOCKET}' attach-session -t test"
  settled attached
}

attached() {
  local clients
  clients=$(tmux list-clients -F x 2>/dev/null)
  [[ -n "${clients}" ]]
}

settled() {
  local delay
  for delay in 0.01 0.02 0.05 0.1 0.2 0.5 1 1 2; do
    "$@" && return 0
    sleep "${delay}"
  done
  "$@"
}

window_named() {
  local names
  names=$(tmux list-windows -a -F '#{window_name}')
  grep -qx "$1" <<<"${names}"
}

load_plugin() {
  local quoted
  quoted=$(printf '%s' "$1" | sed "s/'/'\\\\''/g")
  tmux run-shell "'${quoted}/launcher-revamped.tmux'"
}

key_binding() {
  local table
  table=$(tmux list-keys -T prefix)
  awk -v key="$1" '{ for (i = 1; i < NF; i++) { if ($i == "-T") { if ($(i + 2) == key) { print } break } } }' <<<"${table}"
}

launch() {
  local pane
  pane=$(tmux display-message -p -t test '#{pane_id}')
  # shellcheck disable=SC2086
  TMUX="${TMUX_SOCKET},1,0" TMUX_PANE="${pane}" run --separate-stderr ${REVAMPED_TEST_SHELL:-sh} "${ROOT}/bin/launcher-revamped" launch "$@"
}

settled_windows() {
  local tries=0
  run windows
  while [[ "${lines[1]:-}" != "$1" && "${tries}" -lt 300 ]]; do
    tries=$((tries + 1))
    sleep 0.01
    run windows
  done
}

windows() {
  tmux list-windows -F '#{window_name} #{window_panes} #{pane_current_path}'
}

start_in() {
  local want now tries=0
  want=$(cd "$1" && pwd -P)
  tmux respawn-pane -k -t test -c "$1"
  now=$(tmux display-message -p -t test '#{pane_current_path}')
  while [[ "${now}" != "${want}" ]]; do
    tries=$((tries + 1))
    [[ "${tries}" -le 300 ]] || return 1
    sleep 0.01
    now=$(tmux display-message -p -t test '#{pane_current_path}')
  done
}

@test "entrypoint - loading binds the menu over every app" {
  # Arrange
  set_option @launcher_revamped_apps 'lazygit htop'

  # Act
  load_plugin "${ROOT}"

  # Assert
  run key_binding M-a
  [[ "${output}" == *"display-menu -T Launchers lazygit"*"htop"* ]]
  run tmux list-keys -N -T prefix
  [[ "${output}" == *"Launcher menu"* ]]
}

@test "entrypoint - a menu key the person bound first stays theirs" {
  # Arrange
  tmux bind-key -T prefix M-a display-message mine

  # Act
  load_plugin "${ROOT}"

  # Assert
  run key_binding M-a
  [[ "${output}" == *"display-message mine"* ]]
}

@test "entrypoint - loading again replaces its own menu" {
  # Arrange
  load_plugin "${ROOT}"
  set_option @launcher_revamped_apps 'htop'

  # Act
  load_plugin "${ROOT}"

  # Assert
  run key_binding M-a
  [[ "${output}" == *"Launchers htop"* ]]
}

@test "entrypoint - the bound command launches from a checkout path with a space, a hash and a quote" {
  # Arrange
  local copy="${BATS_TEST_TMPDIR}/it's #1 dir" listing binding
  mkdir -p "${copy}"
  cp -Rf "${ROOT}/bin" "${ROOT}/lib" "${copy}/"
  set_option @launcher_revamped_demo_mode window
  set_option @launcher_revamped_demo_command 'sleep 30'
  listing=$(LAUNCHER_REVAMPED_APPS=demo LAUNCHER_REVAMPED_DEMO_KEY=D sh "${copy}/bin/launcher-revamped" list)
  binding=$(grep 'Launch demo' <<<"${listing}")

  # Act
  tmux run-shell -t test "${binding#*run-shell -b }"

  # Assert
  run windows
  [[ "${lines[1]}" == "demo 1 "* ]]
}

@test "entrypoint - an app set up on the command line launches that way from its key" {
  # Arrange
  attach_host

  # Act
  TMUX="${TMUX_SOCKET},1,0" sh "${ROOT}/bin/launcher-revamped" --apps demo --demo-key T --demo-mode window --demo-name fromcli --demo-command 'sleep 30' apply
  command tmux -S "${HOST}" send-keys -t host C-b T

  # Assert
  settled window_named fromcli
}

@test "entrypoint - the picker key launches the pick from a checkout path with a space, a hash and a quote" {
  # Arrange
  local copy="${BATS_TEST_TMPDIR}/it's #1 dir" quoted
  mkdir -p "${copy}" "${BATS_TEST_TMPDIR}/stubs"
  cp -Rf "${ROOT}/bin" "${ROOT}/lib" "${ROOT}/launcher-revamped.tmux" "${copy}/"
  quoted=$(printf '%s' "${copy}" | sed -e "s/'/'\\\\''/g" -e 's/#/##/g')
  printf '#!/bin/sh\ncat >/dev/null\nprintf "demo\\n"\n' >"${BATS_TEST_TMPDIR}/stubs/fzf"
  chmod +x "${BATS_TEST_TMPDIR}/stubs/fzf"
  tmux set-environment -g PATH "${BATS_TEST_TMPDIR}/stubs:${PATH}"
  set_option @launcher_revamped_apps demo
  set_option @launcher_revamped_picker_key P
  set_option @launcher_revamped_demo_mode window
  set_option @launcher_revamped_demo_command 'sleep 30'
  tmux run-shell "'${quoted}/launcher-revamped.tmux'"
  attach_host

  # Act
  command tmux -S "${HOST}" send-keys -t host C-b P

  # Assert
  settled window_named demo
}

@test "entrypoint - git tracks the entry point and the tool as executable" {
  # Arrange
  local entry=launcher-revamped.tmux tool=bin/launcher-revamped

  # Act
  run git -C "${ROOT}" ls-files --stage -- "${entry}" "${tool}"

  # Assert
  [[ "${lines[0]}" == 100755\ * ]]
  [[ "${lines[1]}" == 100755\ * ]]
}

@test "launch - a window starts at the folder holding the app's marker" {
  # Arrange
  local root
  root=$(cd "${PROJECT}" && pwd -P)
  start_in "${PROJECT}/src"
  set_option @launcher_revamped_demo_mode window
  set_option @launcher_revamped_demo_marker .git
  set_option @launcher_revamped_demo_command 'sleep 30'

  # Act
  launch demo

  # Assert
  [[ "${status}" -eq 0 ]]
  settled_windows "demo 1 ${root}"
  [[ "${lines[1]}" == "demo 1 ${root}" ]]
}

@test "launch - a split opens beside the work in the pane's folder" {
  # Arrange
  start_in "${PROJECT}/src"
  set_option @launcher_revamped_demo_mode split
  set_option @launcher_revamped_demo_command 'sleep 30'

  # Act
  launch demo

  # Assert
  run windows
  [[ "${output}" == "main 2 "* ]]
}

@test "launch - a group opens its members tiled in one window and skips one without a command" {
  # Arrange
  set_option @launcher_revamped_dash_group 'one ghost two'
  set_option @launcher_revamped_one_command 'sleep 30'
  set_option @launcher_revamped_two_command 'sleep 31'
  export LAUNCHER_REVAMPED_GHOST_COMMAND=''

  # Act
  launch dash

  # Assert
  run windows
  [[ "${lines[1]}" == "one 2 "* ]]
}

@test "launch - a group whose members have no command opens nothing" {
  # Arrange
  set_option @launcher_revamped_dash_group 'ghost'
  export LAUNCHER_REVAMPED_GHOST_COMMAND=''

  # Act
  launch dash

  # Assert
  [[ "${status}" -eq 0 ]]
  run windows
  [[ "${#lines[@]}" -eq 1 ]]
}

@test "launch - reuse selects the open window instead of opening another" {
  # Arrange
  set_option @launcher_revamped_demo_mode window
  set_option @launcher_revamped_demo_reuse on
  set_option @launcher_revamped_demo_command 'sleep 30'
  launch demo
  tmux select-window -t main

  # Act
  launch demo

  # Assert
  run windows
  [[ "${#lines[@]}" -eq 2 ]]
  run tmux display-message -p '#{window_name}'
  [[ "${output}" == "demo" ]]
}

@test "launch - reuse opens a window when none is open" {
  # Arrange
  set_option @launcher_revamped_demo_mode window
  set_option @launcher_revamped_demo_reuse on
  set_option @launcher_revamped_demo_command 'sleep 30'

  # Act
  launch demo

  # Assert
  run windows
  [[ "${lines[1]}" == "demo 1 "* ]]
}

@test "launch - a check that passes lets the app open and sees its folder" {
  # Arrange
  start_in "${PROJECT}/src"
  set_option @launcher_revamped_demo_mode window
  set_option @launcher_revamped_demo_marker .git
  set_option @launcher_revamped_demo_command 'sleep 30'
  set_option @launcher_revamped_demo_if '[ -d "$LAUNCHER_PATH/.git" ]'

  # Act
  launch demo

  # Assert
  run windows
  [[ "${lines[1]}" == "demo 1 "* ]]
}

@test "launch - a check that fails keeps the app closed" {
  # Arrange
  set_option @launcher_revamped_demo_mode window
  set_option @launcher_revamped_demo_command 'sleep 30'
  set_option @launcher_revamped_demo_if 'false'

  # Act
  launch demo

  # Assert
  [[ "${status}" -eq 0 ]]
  run windows
  [[ "${#lines[@]}" -eq 1 ]]
}

@test "doctor - a menu key the person bound is reported as skipped" {
  # Arrange
  tmux bind-key -T prefix M-a display-message mine

  # Act
  # shellcheck disable=SC2086
  TMUX="${TMUX_SOCKET},1,0" run --separate-stderr ${REVAMPED_TEST_SHELL:-sh} "${ROOT}/bin/launcher-revamped" doctor

  # Assert
  [[ "${output}" =~ prefix\ M-a\ +warn\ +already\ bound,\ so\ the\ menu\ has\ no\ key ]]
}
