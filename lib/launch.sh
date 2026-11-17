#!/bin/sh

[ -n "${LAUNCHER_REVAMPED_LAUNCH_LOADED:-}" ] && return 0
LAUNCHER_REVAMPED_LAUNCH_LOADED=1

# shellcheck source=SCRIPTDIR/launcher.sh
. "${REVAMPED_LIB:?}/launcher.sh"

launcher_revamped_words() {
  launcher_revamped_words_out=""
  launcher_revamped_words_all="$*"
  set -f
  for launcher_revamped_words_word in ${launcher_revamped_words_all}; do
    launcher_revamped_words_quoted=$(launcher_revamped_quote "${launcher_revamped_words_word}")
    launcher_revamped_words_out="${launcher_revamped_words_out:+${launcher_revamped_words_out} }${launcher_revamped_words_quoted}"
  done
  set +f
  printf '%s' "${launcher_revamped_words_out}"
}

launcher_revamped_walk() {
  launcher_revamped_walk_dir="$1"
  launcher_revamped_walk_depth=0
  case "$3" in
  "" | *[!0-9]*) set -- "$1" "$2" 20 ;;
  *) : ;;
  esac
  while [ "${launcher_revamped_walk_depth}" -lt "$3" ]; do
    if [ -e "${launcher_revamped_walk_dir}/$2" ]; then
      printf '%s' "${launcher_revamped_walk_dir}"
      return 0
    fi
    [ "${launcher_revamped_walk_dir}" != / ] || break
    launcher_revamped_walk_dir="${launcher_revamped_walk_dir%/*}"
    [ -n "${launcher_revamped_walk_dir}" ] || launcher_revamped_walk_dir=/
    launcher_revamped_walk_depth=$((launcher_revamped_walk_depth + 1))
  done
  printf '%s' "$1"
}

launcher_revamped_start() {
  printf '%s\n' "$1" | sed 's/#/##/g'
}

launcher_revamped_scope() {
  launcher_revamped_field "$1" marker
  launcher_revamped_scope_marker="${LAUNCHER_REVAMPED_VALUE:-${LAUNCHER_REVAMPED_S_marker}}"
  if [ -z "${launcher_revamped_scope_marker}" ]; then
    printf '%s' "${LAUNCHER_REVAMPED_PATH}"
    return 0
  fi
  launcher_revamped_walk "${LAUNCHER_REVAMPED_PATH}" "${launcher_revamped_scope_marker}" "${LAUNCHER_REVAMPED_S_max_depth}"
}

launcher_revamped_compose() {
  launcher_revamped_compose_out="$2"
  launcher_revamped_field "$1" env
  [ -z "${LAUNCHER_REVAMPED_VALUE}" ] || launcher_revamped_compose_out="env ${LAUNCHER_REVAMPED_VALUE} ${launcher_revamped_compose_out}"
  launcher_revamped_field "$1" pre
  [ -z "${LAUNCHER_REVAMPED_VALUE}" ] || launcher_revamped_compose_out="${LAUNCHER_REVAMPED_VALUE} && ${launcher_revamped_compose_out}"
  launcher_revamped_field "$1" exit
  [ -z "${LAUNCHER_REVAMPED_VALUE}" ] || launcher_revamped_compose_out="${launcher_revamped_compose_out}; ${LAUNCHER_REVAMPED_VALUE}"
  launcher_revamped_field "$1" host
  if [ -n "${LAUNCHER_REVAMPED_VALUE}" ]; then
    launcher_revamped_compose_host=$(launcher_revamped_quote "${LAUNCHER_REVAMPED_VALUE}")
    launcher_revamped_compose_out=$(launcher_revamped_quote "${launcher_revamped_compose_out}")
    launcher_revamped_compose_out="ssh -t ${launcher_revamped_compose_host} ${launcher_revamped_compose_out}"
  fi
  printf '%s' "${launcher_revamped_compose_out}"
}

launcher_revamped_mode() {
  launcher_revamped_field "$1" mode
  case "${LAUNCHER_REVAMPED_VALUE}" in
  popup)
    launcher_revamped_read_version
    if launcher_revamped_version_ge "${LAUNCHER_REVAMPED_TMUX}" 3.2; then
      printf 'popup'
    else
      printf 'window'
    fi
    ;;
  split) printf 'split' ;;
  *) printf 'window' ;;
  esac
}

launcher_revamped_open() {
  launcher_revamped_open_mode=$(launcher_revamped_mode "$1")
  case "${launcher_revamped_open_mode}" in
  popup)
    launcher_revamped_field "$1" width
    launcher_revamped_open_width="${LAUNCHER_REVAMPED_VALUE}"
    launcher_revamped_field "$1" height
    tmux display-popup -E -w "${launcher_revamped_open_width}" -h "${LAUNCHER_REVAMPED_VALUE}" -d "$2" "$3"
    ;;
  split) tmux split-window -c "$2" "$3" ;;
  *)
    launcher_revamped_field "$1" name
    launcher_revamped_open_name="${LAUNCHER_REVAMPED_VALUE}"
    launcher_revamped_field "$1" reuse
    if [ "${LAUNCHER_REVAMPED_VALUE}" = on ] && tmux select-window -t "=${launcher_revamped_open_name}" >/dev/null 2>&1; then
      return 0
    fi
    tmux new-window -n "${launcher_revamped_open_name}" -c "$2" "$3"
    ;;
  esac
}

launcher_revamped_group() {
  launcher_revamped_load_apps "$1"
  launcher_revamped_group_scope="$2"
  launcher_revamped_group_plan=""
  set -f
  for launcher_revamped_group_member in $1; do
    launcher_revamped_field "${launcher_revamped_group_member}" command
    [ -n "${LAUNCHER_REVAMPED_VALUE}" ] || continue
    if [ -z "${launcher_revamped_group_plan}" ]; then
      launcher_revamped_group_plan=$(printf 'new-window\n-n\n%s\n-c\n%s\n%s\n\n' "${launcher_revamped_group_member}" "${launcher_revamped_group_scope}" "${LAUNCHER_REVAMPED_VALUE}")
    else
      launcher_revamped_group_plan=$(printf '%s\n\nsplit-window\n-c\n%s\n%s\n\n' "${launcher_revamped_group_plan}" "${launcher_revamped_group_scope}" "${LAUNCHER_REVAMPED_VALUE}")
    fi
  done
  set +f
  [ -n "${launcher_revamped_group_plan}" ] || return 0
  launcher_revamped_send "${launcher_revamped_group_plan}

select-layout
tiled"
}

launcher_revamped_launch() {
  launcher_revamped_launch_id="$1"
  shift
  launcher_revamped_launch_args=$(launcher_revamped_words "$@")
  launcher_revamped_launch_rows=$(launcher_revamped_app_rows "${launcher_revamped_launch_id}")
  launcher_revamped_load "${LAUNCHER_REVAMPED_GLOBALS}
${launcher_revamped_launch_rows}"
  launcher_revamped_field "${launcher_revamped_launch_id}" command
  [ -n "${LAUNCHER_REVAMPED_VALUE}" ] || return 0
  launcher_revamped_launch_command="${LAUNCHER_REVAMPED_VALUE}${launcher_revamped_launch_args:+ ${launcher_revamped_launch_args}}"
  launcher_revamped_launch_scope=$(launcher_revamped_scope "${launcher_revamped_launch_id}")
  launcher_revamped_field "${launcher_revamped_launch_id}" if
  if [ -n "${LAUNCHER_REVAMPED_VALUE}" ] && ! LAUNCHER_PATH="${launcher_revamped_launch_scope}" sh -c "${LAUNCHER_REVAMPED_VALUE}"; then
    return 0
  fi
  launcher_revamped_launch_start=$(launcher_revamped_start "${launcher_revamped_launch_scope}")
  launcher_revamped_field "${launcher_revamped_launch_id}" group
  if [ -n "${LAUNCHER_REVAMPED_VALUE}" ]; then
    launcher_revamped_group "${LAUNCHER_REVAMPED_VALUE}" "${launcher_revamped_launch_start}"
    return 0
  fi
  launcher_revamped_launch_full=$(launcher_revamped_compose "${launcher_revamped_launch_id}" "${launcher_revamped_launch_command}")
  launcher_revamped_open "${launcher_revamped_launch_id}" "${launcher_revamped_launch_start}" "${launcher_revamped_launch_full}"
}

launcher_revamped_pick() {
  if ! command -v fzf >/dev/null 2>&1; then
    printf 'launcher-revamped: pick needs fzf. install it with: brew install fzf, or apt install fzf\n' >&2
    return 1
  fi
  launcher_revamped_load "${LAUNCHER_REVAMPED_GLOBALS}"
  launcher_revamped_pick_choice=$(printf '%s\n' "${LAUNCHER_REVAMPED_S_apps}" | awk '{ for (i = 1; i <= NF; i++) { print $i } }' | fzf) || launcher_revamped_pick_choice=""
  tmux set-option -gq "${LAUNCHER_REVAMPED_PICKED}" "${launcher_revamped_pick_choice}"
}

launcher_revamped_launch_picked() {
  launcher_revamped_launch_picked_id=$(tmux display-message -p "#{${LAUNCHER_REVAMPED_PICKED}}" 2>/dev/null) || launcher_revamped_launch_picked_id=""
  [ -n "${launcher_revamped_launch_picked_id}" ] || return 0
  tmux set-option -gqu "${LAUNCHER_REVAMPED_PICKED}"
  launcher_revamped_launch "${launcher_revamped_launch_picked_id}"
}
