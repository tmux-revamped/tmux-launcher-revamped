#!/usr/bin/env bats
# shellcheck disable=SC2030,SC2031,SC2034

# shellcheck source=test/helpers.bash
source "${BATS_TEST_DIRNAME:-.}/helpers.bash"

bats_require_minimum_version 1.5.0

setup() {
  harness_setup
  for name in $(compgen -v LAUNCHER_REVAMPED_) KODOUGU_THEME KODOUGU_ACCENT NO_COLOR; do
    unset "${name}"
  done
}

tool() {
  # shellcheck disable=SC2086
  run ${REVAMPED_TEST_SHELL:-sh} "${REVAMPED_TESTS_DIR}/../bin/launcher-revamped" "$@"
}

plain_tty() {
  local shell_words
  read -r -a shell_words <<<"${REVAMPED_TEST_SHELL:-sh}"
  run python3 "${REVAMPED_TESTS_DIR}/on_tty.py" "${shell_words[@]}" "${REVAMPED_TESTS_DIR}/../bin/launcher-revamped"
}

option() {
  printf '%s' "$2" >"${REVAMPED_TEST_TMUX_DIR}/$(printf '%s' "g.-.@launcher_revamped_$1" | tr -c 'A-Za-z0-9_.-' '_')"
}

@test "commands - list prints every binding apply would make" {
  # Arrange
  local command=list

  # Act
  tool "${command}"

  # Assert
  [[ "${status}" -eq 0 ]]
  [[ "${#lines[@]}" -eq 1 ]]
  [[ "${lines[0]}" == "bind-key -N Launcher menu M-a display-menu -T Launchers lazygit"* ]]
}

@test "commands - list --json prints one JSON object" {
  # Arrange
  export LAUNCHER_REVAMPED_MENU_KEY=none LAUNCHER_REVAMPED_PICKER_KEY=P

  # Act
  tool list --json

  # Assert
  [[ "${output}" == '{"bindings":[["bind-key","-N","Pick an app","P","display-popup","-E",'* ]]
}

@test "commands - an app option in both forms wins over the environment" {
  # Arrange
  export LAUNCHER_REVAMPED_LAZYGIT_KEY=C-x

  # Act
  tool --lazygit-key=C-g --menu-key none list

  # Assert
  [[ "${output}" == "bind-key -N Launch lazygit C-g run-shell"* ]]
}

@test "commands - apply binds every key in one tmux call and prints nothing" {
  # Arrange
  export REVAMPED_TEST_TMUX_ARGV="${BATS_TEST_TMPDIR}/argv"

  # Act
  # shellcheck disable=SC2086
  run --separate-stderr ${REVAMPED_TEST_SHELL:-sh} "${REVAMPED_TESTS_DIR}/../bin/launcher-revamped" apply

  # Assert
  [[ "${status}" -eq 0 ]]
  [[ -z "${output}" ]]
  run grep -c '^bind-key' "${REVAMPED_TEST_TMUX_ARGV}"
  [[ "${output}" == "1" ]]
}

@test "commands - the menu applies the keys and counts them" {
  # Arrange
  harness_hide gum

  # Act
  plain_tty <<<"2"

  # Assert
  [[ "${status}" -eq 0 ]]
  [[ "${output}" == *"Applied. 1 keys are bound."* ]]
}

@test "commands - the menu lists the bindings" {
  # Arrange
  harness_hide gum

  # Act
  plain_tty <<<"1"

  # Assert
  [[ "${output}" == *"display-menu -T Launchers"* ]]
}

@test "commands - the menu runs doctor" {
  # Arrange
  harness_hide gum

  # Act
  plain_tty <<<"3"

  # Assert
  [[ "${output}" =~ tmux\ +ok ]]
}

@test "commands - the menu shows the help page" {
  # Arrange
  harness_hide gum

  # Act
  plain_tty <<<"4"

  # Assert
  [[ "${output}" == *"launcher-revamped - terminal apps one key away in tmux"* ]]
}

@test "commands - doctor rows name each app, fzf and the picker's remedy" {
  # Arrange
  stub_command lazygit
  option apps 'lazygit launcher-revamped-gone far'
  option far_host box
  harness_hide fzf gum

  # Act
  tool doctor

  # Assert
  [[ "${status}" -eq 0 ]]
  [[ "${output}" =~ lazygit\ +ok\ +[^\ ]*/stubs/lazygit ]]
  [[ "${output}" =~ launcher-revamped-gone\ +warn\ +launcher-revamped-gone\ is\ not\ installed ]]
  [[ "${output}" =~ far\ +ok\ +runs\ on\ box ]]
  [[ "${output}" =~ fzf\ +warn\ +the\ picker\ needs\ it ]]
}

@test "commands - doctor finds fzf and skips an app without a command" {
  # Arrange
  stub_command fzf
  option apps 'ghost'
  export LAUNCHER_REVAMPED_GHOST_COMMAND=''

  # Act
  tool doctor

  # Assert
  [[ "${output}" =~ fzf\ +ok ]]
  [[ "${output}" != *"ghost"* ]]
}

@test "commands - an unknown option is a usage error even without a value" {
  # Arrange
  local option=--colour

  # Act
  tool "${option}"

  # Assert
  [[ "${status}" -eq 1 ]]
  [[ "${output}" == "launcher-revamped: unknown option '--colour'. run 'launcher-revamped help' for usage." ]]
}

@test "commands - an unknown option with a value is a usage error" {
  # Arrange
  local option=--colour=red

  # Act
  tool "${option}" list

  # Assert
  [[ "${status}" -eq 1 ]]
  [[ "${output}" == "launcher-revamped: unknown option '--colour'. run 'launcher-revamped help' for usage." ]]
}

@test "commands - a setting option without its value is a usage error" {
  # Arrange
  local option=--menu-key

  # Act
  tool list "${option}"

  # Assert
  [[ "${status}" -eq 1 ]]
  [[ "${output}" == "launcher-revamped: option '--menu-key' needs a value. run 'launcher-revamped help' for usage." ]]
}

@test "commands - a single-dash option is a usage error" {
  # Arrange
  local option=-x

  # Act
  tool "${option}"

  # Assert
  [[ "${status}" -eq 1 ]]
  [[ "${output}" == "launcher-revamped: unknown option '-x'. run 'launcher-revamped help' for usage." ]]
}

@test "commands - --json with any command but list is a usage error" {
  # Arrange
  local flag=--json

  # Act
  tool "${flag}" apply

  # Assert
  [[ "${status}" -eq 1 ]]
  [[ "${output}" == "launcher-revamped: option '--json' works only with list. run 'launcher-revamped help' for usage." ]]
}

@test "commands - -- ends the options and --theme takes a value" {
  # Arrange
  local command=list

  # Act
  tool --theme nord -- "${command}"

  # Assert
  [[ "${status}" -eq 0 ]]
  [[ "${lines[0]}" == bind-key\ * ]]
}

@test "commands - --theme= sets the look" {
  # Arrange
  local command=version

  # Act
  tool --theme=mono "${command}"

  # Assert
  [[ "${status}" -eq 0 ]]
  [[ "${lines[0]}" =~ ^launcher-revamped\ [0-9]+\.[0-9]+\.[0-9]+$ ]]
}

@test "commands - an inherited guard variable of the plugin is ignored" {
  # Arrange
  export LAUNCHER_REVAMPED_LAUNCHER_LOADED=1 LAUNCHER_REVAMPED_CORE_LOADED=1

  # Act
  tool version

  # Assert
  [[ "${status}" -eq 0 ]]
  [[ "${lines[0]}" =~ ^launcher-revamped\ [0-9]+\.[0-9]+\.[0-9]+$ ]]
}

@test "commands - an accent from the environment reaches the interface" {
  # Arrange
  export LAUNCHER_REVAMPED_ACCENT='#89DCEB'

  # Act
  tool version

  # Assert
  [[ "${status}" -eq 0 ]]
  [[ "${lines[1]}" == tmux:\ * ]]
}
