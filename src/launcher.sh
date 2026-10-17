#!/usr/bin/env bash

PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
_SELF="${PLUGIN_DIR}/src/launcher.sh"
_PROMPT_OPTION="@launcher_prompt_value"
_PICKED_OPTION="@launcher_picked"

# shellcheck source=/dev/null
source "${PLUGIN_DIR}/src/lib/launcher/launcher.sh"
# shellcheck source=/dev/null
source "${PLUGIN_DIR}/src/lib/utils/has-command.sh"

_tmux() { [[ -n "${LAUNCHER_DRY_RUN:-}" ]] && { echo "tmux $*"; return 0; }; command tmux "$@"; }

_run() { [[ -n "${LAUNCHER_DRY_RUN:-}" ]] && { echo "run $*"; return 0; }; "$@"; }

get_opt() {
  local v
  v="$(tmux show-option -gqv "${1}" 2>/dev/null)"
  echo "${v:-${2}}"
}

_pane_path() { _tmux display-message -p '#{pane_current_path}'; }

_guard() { sh -c "${1}"; }

_window_exists() { _tmux select-window -t "=${1}" >/dev/null 2>&1; }

_first_word() { printf '%s' "${1%% *}"; }

_self_command() {
  local out word
  out="bash $(printf '%q' "${_SELF}")"
  for word in "$@"; do
    out="${out} $(printf '%q' "${word}")"
  done
  printf '%s' "${out}"
}

_quote_words() {
  local out="" input word
  local -a words
  for input in "$@"; do
    read -r -a words <<< "${input}"
    for word in "${words[@]}"; do
      out="${out:+${out} }$(printf '%q' "${word}")"
    done
  done
  printf '%s' "${out}"
}

_tmux_quote() {
  local quote="'" escaped="'\\''"
  printf "'%s'" "${1//"${quote}"/${escaped}}"
}

_launch() {
  local eff="${1}" name="${2}" path="${3}" cmd="${4}" width="${5}" height="${6}" reuse="${7}"
  case "${eff}" in
    popup)
      _tmux display-popup -E -w "${width}" -h "${height}" -d "${path}" "${cmd}"
      ;;
    split)
      _tmux split-window -c "${path}" "${cmd}"
      ;;
    *)
      if [[ "${reuse}" == "on" ]] && _window_exists "${name}"; then
        return 0
      fi
      _tmux new-window -n "${name}" -c "${path}" "${cmd}"
      ;;
  esac
}

_launch_group() {
  local members="${1}" path="${2}" first=1 m mcmd
  # shellcheck disable=SC2086
  for m in ${members}; do
    [[ -z "${m}" ]] && continue
    mcmd="$(get_opt "@launcher_${m}_command" "$(default_command "${m}")")"
    [[ -z "${mcmd}" ]] && continue
    if [[ "${first}" -eq 1 ]]; then
      _tmux new-window -n "${m}" -c "${path}" "${mcmd}"
      first=0
    else
      _tmux split-window -c "${path}" "${mcmd}"
    fi
  done
  [[ "${first}" -eq 0 ]] && _tmux select-layout tiled
  return 0
}

dispatch() {
  local id="${1:-}" arg
  [[ -z "${id}" ]] && return 0
  shift
  arg="$(_quote_words "$@")"

  local cmd pred path marker maxdepth scope group
  local env_vars pre exit_hook remote mode ver eff name width height reuse full

  cmd="$(get_opt "@launcher_${id}_command" "$(default_command "${id}")")"
  [[ -z "${cmd}" ]] && return 0

  ver="$(tmux_version)"
  path="$(_pane_path)"

  marker="$(get_opt "@launcher_${id}_marker" "$(get_opt @launcher_marker "")")"
  if [[ -n "${marker}" ]]; then
    maxdepth="$(get_opt @launcher_max_depth 20)"
    scope="$(scoped_path "${path}" "${marker}" "${maxdepth}")"
  else
    scope="${path}"
  fi

  pred="$(get_opt "@launcher_${id}_if" "")"
  if [[ -n "${pred}" ]]; then
    LAUNCHER_PATH="${scope}" _guard "${pred}" || return 0
  fi

  group="$(get_opt "@launcher_${id}_group" "")"
  if [[ -n "${group}" ]]; then
    _launch_group "${group}" "${scope}"
    return 0
  fi

  env_vars="$(get_opt "@launcher_${id}_env" "")"
  pre="$(get_opt "@launcher_${id}_pre" "")"
  exit_hook="$(get_opt "@launcher_${id}_exit" "")"
  remote="$(get_opt "@launcher_${id}_host" "")"
  [[ -n "${arg}" ]] && cmd="${cmd} ${arg}"

  full="$(compose_command "${env_vars}" "${pre}" "${cmd}" "${exit_hook}")"
  [[ -n "${remote}" ]] && full="$(ssh_wrap "${remote}" "${full}")"

  mode="$(get_opt "@launcher_${id}_mode" "$(default_mode "${id}")")"
  eff="$(effective_mode "${mode}" "${ver}")"
  name="$(get_opt "@launcher_${id}_name" "${id}")"
  width="$(get_opt "@launcher_${id}_width" "80%")"
  height="$(get_opt "@launcher_${id}_height" "80%")"
  reuse="$(get_opt "@launcher_${id}_reuse" "")"

  _launch "${eff}" "${name}" "${scope}" "${full}" "${width}" "${height}" "${reuse}"
}

pick() {
  local apps choice
  apps="$(get_opt @launcher_apps "lazygit yazi")"
  # shellcheck disable=SC2086
  choice="$(printf '%s\n' ${apps} | _run fzf)"
  _tmux set-option -gq "${_PICKED_OPTION}" "${choice}"
}

dispatch_picked() {
  local choice
  choice="$(get_opt "${_PICKED_OPTION}" "")"
  _tmux set-option -gqu "${_PICKED_OPTION}"
  [[ -z "${choice}" ]] && return 0
  dispatch "${choice}"
}

_bind_app() {
  local id="${1}" key cmd prompt host skip first
  key="$(get_opt "@launcher_${id}_key" "")"
  cmd="$(get_opt "@launcher_${id}_command" "$(default_command "${id}")")"
  [[ -z "${key}" || -z "${cmd}" ]] && return 0

  host="$(get_opt "@launcher_${id}_host" "")"
  skip="$(get_opt @launcher_skip_missing "")"
  if [[ "${skip}" == "on" && -z "${host}" ]]; then
    first="$(_first_word "${cmd}")"
    has_command "${first}" || return 0
  fi

  prompt="$(get_opt "@launcher_${id}_prompt" "")"
  if [[ -n "${prompt}" ]]; then
    _tmux bind-key "${key}" command-prompt -p "${prompt}" \
      "set-option -gq ${_PROMPT_OPTION} \"%%%\" ; run-shell -b $(_tmux_quote "$(_self_command dispatch "${id}") #{q:${_PROMPT_OPTION}}")"
  else
    _tmux bind-key "${key}" run-shell -b "$(_self_command dispatch "${id}")"
  fi
}

_bind_menu() {
  local key apps id name args
  key="$(get_opt @launcher_menu_key "M-a")"
  [[ "${key}" == "off" ]] && return 0
  apps="$(get_opt @launcher_apps "lazygit yazi")"
  args=(display-menu -T "Launchers")
  # shellcheck disable=SC2086
  for id in ${apps}; do
    [[ -z "${id}" ]] && continue
    name="$(get_opt "@launcher_${id}_name" "${id}")"
    args+=("${name}" "" "run-shell -b $(_tmux_quote "$(_self_command dispatch "${id}")")")
  done
  _tmux bind-key "${key}" "${args[@]}"
}

_bind_picker() {
  local key
  key="$(get_opt @launcher_picker_key "")"
  [[ -z "${key}" ]] && return 0
  _tmux bind-key "${key}" display-popup -E "$(_self_command pick)" '\;' \
    run-shell -b "$(_self_command dispatch-picked)"
}

apply_launcher() {
  local apps id
  apps="$(get_opt @launcher_apps "lazygit yazi")"
  # shellcheck disable=SC2086
  for id in ${apps}; do
    [[ -z "${id}" ]] && continue
    _bind_app "${id}"
  done
  _bind_menu
  _bind_picker
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  case "${1:-}" in
    dispatch) shift; dispatch "$@" ;;
    pick)     pick ;;
    dispatch-picked) dispatch_picked ;;
    *)        apply_launcher ;;
  esac
fi
