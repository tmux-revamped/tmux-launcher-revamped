#!/usr/bin/env bash

[[ -n "${_LAUNCHER_REVAMPED_LOADED:-}" ]] && return 0
_LAUNCHER_REVAMPED_LOADED=1

parse_tmux_version() {
  printf '%s\n' "${1}" | sed -En 's/^tmux[ -]([a-z]+-)?([0-9]+\.[0-9]+).*/\2/p'
}

version_ge() {
  local have_major have_minor want_major want_minor
  [[ "${1}" =~ ^([0-9]+)(\.([0-9]+))? ]] || return 1
  have_major="${BASH_REMATCH[1]}"
  have_minor="${BASH_REMATCH[3]:-0}"
  [[ "${2}" =~ ^([0-9]+)(\.([0-9]+))? ]] || return 1
  want_major="${BASH_REMATCH[1]}"
  want_minor="${BASH_REMATCH[3]:-0}"
  (( 10#${have_major} > 10#${want_major} )) && return 0
  (( 10#${have_major} == 10#${want_major} && 10#${have_minor} >= 10#${want_minor} ))
}

effective_mode() {
  case "${1}" in
    popup)
      if version_ge "${2}" 3.2; then echo "popup"; else echo "window"; fi
      ;;
    split) echo "split" ;;
    window) echo "window" ;;
    *) echo "window" ;;
  esac
}

ssh_wrap() {
  if [[ -n "${1}" ]]; then
    printf 'ssh -t %q %q' "${1}" "${2}"
  else
    printf '%s' "${2}"
  fi
}

compose_command() {
  local env_vars="${1}" pre="${2}" cmd="${3}" exit_hook="${4}" out
  out="${cmd}"
  [[ -n "${env_vars}" ]] && out="env ${env_vars} ${out}"
  [[ -n "${pre}" ]] && out="${pre} && ${out}"
  [[ -n "${exit_hook}" ]] && out="${out}; ${exit_hook}"
  printf '%s' "${out}"
}

_path_has_marker() { [ -e "${1}/${2}" ]; }

walk_up_marker() {
  local dir="${1}" marker="${2}" max="${3:-20}" depth=0
  [[ -z "${dir}" || -z "${marker}" ]] && return 1
  while [[ "${depth}" -lt "${max}" ]]; do
    if _path_has_marker "${dir}" "${marker}"; then
      printf '%s' "${dir}"
      return 0
    fi
    [[ "${dir}" == "/" ]] && break
    dir="$(dirname "${dir}")"
    depth=$((depth + 1))
  done
  return 1
}

scoped_path() {
  local root
  if root="$(walk_up_marker "${1}" "${2}" "${3}")"; then
    printf '%s' "${root}"
  else
    printf '%s' "${1}"
  fi
}

default_command() {
  case "${1}" in
    lazygit) echo "lazygit" ;;
    yazi)    echo "yazi" ;;
    *)       echo "${1}" ;;
  esac
}
default_mode() {
  case "${1}" in
    yazi) echo "window" ;;
    *)    echo "popup" ;;
  esac
}

_tmux_version_string() { tmux -V 2>/dev/null; }

tmux_version() { parse_tmux_version "$(_tmux_version_string)"; }

export -f parse_tmux_version
export -f version_ge
export -f effective_mode
export -f ssh_wrap
export -f compose_command
export -f _path_has_marker
export -f walk_up_marker
export -f scoped_path
export -f default_command
export -f default_mode
export -f _tmux_version_string
export -f tmux_version
