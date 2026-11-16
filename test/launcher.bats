#!/usr/bin/env bats
# shellcheck disable=SC2016,SC2030,SC2031,SC2034

# shellcheck source=test/helpers.bash
source "${BATS_TEST_DIRNAME:-.}/helpers.bash"

setup() {
  harness_setup
  for name in $(compgen -v LAUNCHER_REVAMPED_); do
    unset "${name}"
  done
}

option() {
  printf '%s' "$2" >"${REVAMPED_TEST_TMUX_DIR}/$(printf '%s' "g.-.@launcher_revamped_$1" | tr -c 'A-Za-z0-9_.-' '_')"
}

plan_at() {
  export REVAMPED_TEST_TMUX_VERSION="$1"
  lib_run launcher 'launcher_revamped_plan; launcher_revamped_lines'
}

@test "launcher - the version is read from tmux -V, next and rc builds included" {
  # Arrange
  local script='for v in "tmux 3.6" "tmux next-3.7" "tmux 3.5a" "tmux master"; do printf "[%s]" "$(launcher_revamped_parse_version "${v}")"; done'

  # Act
  lib_run launcher "${script}"

  # Assert
  [[ "${output}" == "[3.6][3.7][3.5][]" ]]
}

@test "launcher - version_ge compares major and minor numbers" {
  # Arrange
  local script='for p in "3.2 3.2" "3.10 3.2" "4.0 3.9" "3.1 3.2" "2.9 3.0" "x 3.2" ""; do set -- ${p}; if launcher_revamped_version_ge "${1:-}" "${2:-}"; then printf y; else printf n; fi; done'

  # Act
  lib_run launcher "${script}"

  # Assert
  [[ "${output}" == "yyynnnn" ]]
}

@test "launcher - the defaults bind only the menu over lazygit and yazi" {
  # Arrange
  option menu_key ''

  # Act
  plan_at 3.6

  # Assert
  [[ "${#lines[@]}" -eq 1 ]]
  [[ "${lines[0]}" == "bind-key -N Launcher menu M-a display-menu -T Launchers lazygit '' run-shell -b "*" launch "*"lazygit"*" yazi '' run-shell -b "*"yazi"* ]]
}

@test "launcher - tmux 3.0 gets no notes" {
  # Arrange
  option apps lazygit

  # Act
  plan_at 3.0

  # Assert
  [[ "${lines[0]}" == "bind-key M-a display-menu -T Launchers lazygit"* ]]
}

@test "launcher - an app key runs launch for that app" {
  # Arrange
  option lazygit_key C-g

  # Act
  plan_at 3.6

  # Assert
  [[ "${lines[0]}" == "bind-key -N Launch lazygit C-g run-shell -b '"*"/bin/launcher-revamped' launch 'lazygit'" ]]
}

@test "launcher - an app prompt sends the typed words through a tmux option" {
  # Arrange
  option man_key M
  option apps man
  option man_prompt 'man:'

  # Act
  plan_at 3.6

  # Assert
  [[ "${lines[0]}" == "bind-key -N Launch man M command-prompt -p man: set-option -gq @launcher_revamped_typed \"%%%\" ; run-shell -b "*"/bin/launcher-revamped"*" launch "*"man"*" #{q:@launcher_revamped_typed}'" ]]
}

@test "launcher - skip-missing drops a key whose command is not installed and keeps a remote one" {
  # Arrange
  option apps 'gone here far'
  option skip_missing on
  option gone_key G
  option gone_command 'launcher-revamped-not-installed --flag'
  option here_key H
  option here_command 'sh -c true'
  option far_key F
  option far_command 'launcher-revamped-not-installed'
  option far_host box

  # Act
  plan_at 3.6

  # Assert
  [[ "${output}" != *" G run-shell"* ]]
  [[ "${output}" == *" H run-shell"* ]]
  [[ "${output}" == *" F run-shell"* ]]
}

@test "launcher - an app without a command binds no key" {
  # Arrange
  option apps lazygit
  option lazygit_key C-g
  export LAUNCHER_REVAMPED_LAZYGIT_COMMAND=''

  # Act
  plan_at 3.6

  # Assert
  [[ "${output}" != *"C-g"* ]]
}

@test "launcher - a menu key of none binds no menu" {
  # Arrange
  option menu_key none

  # Act
  plan_at 3.6

  # Assert
  [[ -z "${output}" ]]
}

@test "launcher - an empty menu key from the environment binds no menu" {
  # Arrange
  export LAUNCHER_REVAMPED_MENU_KEY=''

  # Act
  plan_at 3.6

  # Assert
  [[ -z "${output}" ]]
}

@test "launcher - an empty app list binds an empty menu" {
  # Arrange
  export LAUNCHER_REVAMPED_APPS=''

  # Act
  plan_at 3.6

  # Assert
  [[ "${output}" == "bind-key -N Launcher menu M-a display-menu -T Launchers" ]]
}

@test "launcher - a picker key opens pick in a popup and launches the pick after it closes" {
  # Arrange
  option picker_key P
  option menu_key none

  # Act
  plan_at 3.6

  # Assert
  [[ "${lines[0]}" == "bind-key -N Pick an app P display-popup -E '"*"/bin/launcher-revamped' pick \\; run-shell -b '"*"/bin/launcher-revamped' launch-picked" ]]
}

@test "launcher - the tool path doubles a hash and escapes a quote" {
  # Arrange
  export PROBE_LIB="/tmp/it's #1/lib"

  # Act
  lib_run launcher 'REVAMPED_LIB="${PROBE_LIB}"; launcher_revamped_plan_tool; printf "%s" "${LAUNCHER_REVAMPED_TOOL}"'

  # Assert
  [[ "${output}" == "'/tmp/it'\\''s ##1/bin/launcher-revamped'" ]]
}

@test "launcher - a word is quoted for sh with every quote escaped" {
  # Arrange
  export PROBE_WORD="it's a b"

  # Act
  lib_run launcher 'launcher_revamped_quote "${PROBE_WORD}"'

  # Assert
  [[ "${output}" == "'it'\\''s a b'" ]]
}

@test "launcher - apply sends every binding to tmux in one call" {
  # Arrange
  option lazygit_key C-g
  option picker_key P
  export REVAMPED_TEST_TMUX_ARGV="${BATS_TEST_TMPDIR}/argv"

  # Act
  lib_run launcher launcher_revamped_apply

  # Assert
  run grep -c '^bind-key' "${REVAMPED_TEST_TMUX_ARGV}"
  [[ "${output}" == "1" ]]
  run grep -c '|Launchers|lazygit||run-shell' "${REVAMPED_TEST_TMUX_ARGV}"
  [[ "${output}" == "1" ]]
}

@test "launcher - apply calls tmux for nothing when no key is bound" {
  # Arrange
  option menu_key none
  export REVAMPED_TEST_TMUX_ARGV="${BATS_TEST_TMPDIR}/argv"

  # Act
  lib_run launcher launcher_revamped_apply

  # Assert
  [[ "${status}" -eq 0 ]]
  run grep -c '^bind-key' "${REVAMPED_TEST_TMUX_ARGV}"
  [[ "${output}" == "0" ]]
}

@test "launcher - json lists every binding with empty arguments kept" {
  # Arrange
  option apps lazygit

  # Act
  lib_run launcher 'launcher_revamped_plan; launcher_revamped_json'

  # Assert
  [[ "${output}" == '{"bindings":[["bind-key","-N","Launcher menu","M-a","display-menu","-T","Launchers","lazygit","","run-shell -b '* ]]
}

@test "launcher - json escapes quotes and backslashes" {
  # Arrange
  local script='LAUNCHER_REVAMPED_PLAN="$(printf "a\\\\b\nsay \"hi\"\n\n")"; launcher_revamped_json'

  # Act
  lib_run launcher "${script}"

  # Assert
  [[ "${output}" == '{"bindings":[["a\\b","say \"hi\""]]}' ]]
}

@test "launcher - bindings counts the bind-key commands" {
  # Arrange
  option lazygit_key C-g

  # Act
  lib_run launcher 'launcher_revamped_plan; launcher_revamped_bindings'

  # Assert
  [[ "${output}" == "2" ]]
}

@test "launcher - a setting name comes from a global or an app field" {
  # Arrange
  local script='for o in --menu-key --lazygit-key --my-app-exit --_key --lazygit- --lazygit-colour --colour; do printf "[%s]" "$(launcher_revamped_setting_name "$o")"; done'

  # Act
  lib_run launcher "${script}"

  # Assert
  [[ "${output}" == "[menu_key][lazygit_key][my_app_exit][][][][]" ]]
}

@test "launcher - an app setting comes from the environment, then the tmux option, then its default" {
  # Arrange
  option lazygit_mode split
  option yazi_width 50%
  export LAUNCHER_REVAMPED_LAZYGIT_MODE=window
  local script='launcher_revamped_load_apps "lazygit yazi"; for f in "lazygit mode" "yazi mode" "yazi width" "yazi height" "yazi name"; do set -- ${f}; launcher_revamped_field "$1" "$2"; printf "[%s]" "${LAUNCHER_REVAMPED_VALUE}"; done'

  # Act
  lib_run launcher "${script}"

  # Assert
  [[ "${output}" == "[window][window][50%][80%][yazi]" ]]
}

@test "launcher - loading no apps asks tmux nothing" {
  # Arrange
  local apps=''

  # Act
  lib_run launcher "launcher_revamped_load_apps '${apps}'"

  # Assert
  [[ "${status}" -eq 0 ]]
  [[ ! -s "${REVAMPED_TEST_TMUX_LOG}" ]]
}
