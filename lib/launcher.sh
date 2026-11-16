#!/bin/sh

[ -n "${LAUNCHER_REVAMPED_LAUNCHER_LOADED:-}" ] && return 0
LAUNCHER_REVAMPED_LAUNCHER_LOADED=1

# shellcheck source=SCRIPTDIR/state.sh
. "${REVAMPED_LIB:?}/state.sh"

launcher_revamped_app_rows() {
  printf '%s\n' "$1" | LAUNCHER_REVAMPED_ROW_FIELDS="${LAUNCHER_REVAMPED_FIELDS}" awk '
    BEGIN { count = split(ENVIRON["LAUNCHER_REVAMPED_ROW_FIELDS"], field, " ") }
    {
      for (word = 1; word <= NF; word++) {
        for (at = 1; at <= count; at++) {
          value = ""
          if (field[at] == "command" || field[at] == "name") { value = $word }
          if (field[at] == "mode") { value = ($word == "yazi") ? "window" : "popup" }
          if (field[at] == "width" || field[at] == "height") { value = "80%" }
          print $word "_" field[at] "\t" value "\tA"
        }
      }
    }
  '
}

launcher_revamped_format() {
  printf '%s\n' "$1" | awk -F '\t' '{ printf "\t#{@launcher_revamped_%s}", $1 }'
}

launcher_revamped_resolve() {
  env | LAUNCHER_REVAMPED_ROWS="$1" LAUNCHER_REVAMPED_LIVE="$2" awk '
    BEGIN {
      count = split(ENVIRON["LAUNCHER_REVAMPED_ROWS"], rows, "\n")
      split(ENVIRON["LAUNCHER_REVAMPED_LIVE"], live, "\t")
      for (i = 1; i <= count; i++) {
        split(rows[i], field, "\t")
        name[i] = field[1]
        class[i] = (field[3] == "") ? "S" : field[3]
        gsub(/[^A-Za-z0-9_]/, "_", name[i])
        value[i] = (live[i + 1] != "") ? live[i + 1] : field[2]
        want["LAUNCHER_REVAMPED_" toupper(name[i])] = i
      }
    }
    {
      at = index($0, "=")
      key = substr($0, 1, at - 1)
      if (key in want) { value[want[key]] = substr($0, at + 1) }
    }
    END { for (i = 1; i <= count; i++) { print class[i] "\t" name[i] "\t" value[i] } }
  '
}

launcher_revamped_display() {
  if [ -n "${TMUX_PANE:-}" ]; then
    tmux display-message -p -t "${TMUX_PANE}" "$1" 2>/dev/null
    return
  fi
  tmux display-message -p "$1" 2>/dev/null
}

launcher_revamped_load() {
  launcher_revamped_load_format=$(launcher_revamped_format "$1")
  launcher_revamped_load_live=$(launcher_revamped_display "#{pane_current_path}${launcher_revamped_load_format}") || launcher_revamped_load_live=""
  # shellcheck disable=SC2034
  LAUNCHER_REVAMPED_PATH="${launcher_revamped_load_live%%	*}"
  launcher_revamped_load_values=$(launcher_revamped_resolve "$1" "${launcher_revamped_load_live}")
  while IFS='	' read -r launcher_revamped_load_class launcher_revamped_load_name launcher_revamped_load_value; do
    IFS= read -r "LAUNCHER_REVAMPED_${launcher_revamped_load_class}_${launcher_revamped_load_name}" <<EOF
${launcher_revamped_load_value}
EOF
  done <<EOF
${launcher_revamped_load_values}
EOF
}

launcher_revamped_load_apps() {
  launcher_revamped_load_apps_rows=$(launcher_revamped_app_rows "$1")
  [ -n "${launcher_revamped_load_apps_rows}" ] || return 0
  launcher_revamped_load "${launcher_revamped_load_apps_rows}"
}

launcher_revamped_field() {
  launcher_revamped_field_var=$(printf '%s\n' "$1" | tr -c 'A-Za-z0-9_\n' '_')
  eval "LAUNCHER_REVAMPED_VALUE=\${LAUNCHER_REVAMPED_A_${launcher_revamped_field_var}_$2-}"
}

launcher_revamped_quote() {
  launcher_revamped_quote_body=$(printf '%s\n' "$1" | sed "s/'/'\\\\''/g")
  printf "'%s'" "${launcher_revamped_quote_body}"
}

launcher_revamped_parse_version() {
  printf '%s\n' "$1" | sed -En 's/^tmux[ -]([a-z]+-)?([0-9]+\.[0-9]+).*/\2/p'
}

launcher_revamped_version_ge() {
  case "$1:$2" in
  *[!0-9.:]* | :* | *:) return 1 ;;
  *) ;;
  esac
  launcher_revamped_version_ge_have="${1%%.*}"
  launcher_revamped_version_ge_want="${2%%.*}"
  [ "${launcher_revamped_version_ge_have}" -gt "${launcher_revamped_version_ge_want}" ] && return 0
  [ "${launcher_revamped_version_ge_have}" -eq "${launcher_revamped_version_ge_want}" ] || return 1
  launcher_revamped_version_ge_have="${1#*.}"
  launcher_revamped_version_ge_want="${2#*.}"
  [ "${launcher_revamped_version_ge_have%%.*}" -ge "${launcher_revamped_version_ge_want%%.*}" ]
}

launcher_revamped_read_version() {
  launcher_revamped_read_version_raw=$(tmux -V 2>/dev/null) || launcher_revamped_read_version_raw=""
  LAUNCHER_REVAMPED_TMUX=$(launcher_revamped_parse_version "${launcher_revamped_read_version_raw}")
}

launcher_revamped_emit() {
  for launcher_revamped_emit_arg in "$@"; do
    LAUNCHER_REVAMPED_PLAN="${LAUNCHER_REVAMPED_PLAN}${launcher_revamped_emit_arg}
"
  done
  LAUNCHER_REVAMPED_PLAN="${LAUNCHER_REVAMPED_PLAN}
"
}

launcher_revamped_bind() {
  launcher_revamped_bind_key="$1"
  launcher_revamped_bind_desc="$2"
  shift 2
  set -- "${launcher_revamped_bind_key}" "$@"
  [ "${LAUNCHER_REVAMPED_NOTES}" != 1 ] || set -- -N "${launcher_revamped_bind_desc}" "$@"
  launcher_revamped_emit bind-key "$@"
}

launcher_revamped_plan_tool() {
  launcher_revamped_plan_tool_path=$(printf '%s\n' "${REVAMPED_LIB%/lib}/bin/launcher-revamped" | sed -e 's/#/##/g')
  LAUNCHER_REVAMPED_TOOL=$(launcher_revamped_quote "${launcher_revamped_plan_tool_path}")
}

launcher_revamped_missing() {
  [ "${LAUNCHER_REVAMPED_S_skip_missing}" = on ] || return 1
  launcher_revamped_field "$1" host
  [ -z "${LAUNCHER_REVAMPED_VALUE}" ] || return 1
  ! command -v "${2%% *}" >/dev/null 2>&1
}

launcher_revamped_plan_app() {
  launcher_revamped_field "$1" key
  launcher_revamped_plan_app_key="${LAUNCHER_REVAMPED_VALUE}"
  launcher_revamped_field "$1" command
  [ -n "${launcher_revamped_plan_app_key}" ] && [ -n "${LAUNCHER_REVAMPED_VALUE}" ] || return 0
  ! launcher_revamped_missing "$1" "${LAUNCHER_REVAMPED_VALUE}" || return 0
  launcher_revamped_field "$1" name
  launcher_revamped_plan_app_note="Launch ${LAUNCHER_REVAMPED_VALUE}"
  launcher_revamped_plan_app_id=$(launcher_revamped_quote "$1")
  launcher_revamped_plan_app_run="TMUX_PANE=#{pane_id} ${LAUNCHER_REVAMPED_TOOL} launch ${launcher_revamped_plan_app_id}"
  launcher_revamped_field "$1" prompt
  if [ -z "${LAUNCHER_REVAMPED_VALUE}" ]; then
    launcher_revamped_bind "${launcher_revamped_plan_app_key}" "${launcher_revamped_plan_app_note}" run-shell -b "${launcher_revamped_plan_app_run}"
    return 0
  fi
  launcher_revamped_plan_app_typed=$(launcher_revamped_quote "${launcher_revamped_plan_app_run} #{q:${LAUNCHER_REVAMPED_TYPED}}")
  launcher_revamped_plan_app_then="set-option -gq ${LAUNCHER_REVAMPED_TYPED} \"%%%\" ; run-shell -b ${launcher_revamped_plan_app_typed}"
  launcher_revamped_bind "${launcher_revamped_plan_app_key}" "${launcher_revamped_plan_app_note}" command-prompt -p "${LAUNCHER_REVAMPED_VALUE}" "${launcher_revamped_plan_app_then}"
}

launcher_revamped_binding() {
  tmux list-keys -T prefix 2>/dev/null | awk -v key="$1" '{ for (i = 1; i < NF; i++) { if ($i == "-T") { if ($(i + 2) == key) { print } break } } }'
}

launcher_revamped_menu_items() {
  set -f
  for launcher_revamped_menu_items_id in ${LAUNCHER_REVAMPED_S_apps}; do
    launcher_revamped_field "${launcher_revamped_menu_items_id}" name
    launcher_revamped_menu_items_quoted=$(launcher_revamped_quote "${launcher_revamped_menu_items_id}")
    launcher_revamped_menu_items_run=$(launcher_revamped_quote "TMUX_PANE=#{pane_id} ${LAUNCHER_REVAMPED_TOOL} launch ${launcher_revamped_menu_items_quoted}")
    printf '%s\n%s\n%s\n' "${LAUNCHER_REVAMPED_VALUE}" "${LAUNCHER_REVAMPED_EMPTY}" "run-shell -b ${launcher_revamped_menu_items_run}"
  done
  set +f
}

launcher_revamped_plan_menu() {
  launcher_revamped_plan_menu_key="${LAUNCHER_REVAMPED_S_menu_key}"
  LAUNCHER_REVAMPED_MENU_TAKEN=""
  case "${launcher_revamped_plan_menu_key}" in
  "" | none) return 0 ;;
  *) : ;;
  esac
  launcher_revamped_plan_menu_bound=$(launcher_revamped_binding "${launcher_revamped_plan_menu_key}")
  case "${launcher_revamped_plan_menu_bound}" in
  "" | *launcher-revamped*) : ;;
  *)
    # shellcheck disable=SC2034
    LAUNCHER_REVAMPED_MENU_TAKEN="${launcher_revamped_plan_menu_key}"
    return 0
    ;;
  esac
  launcher_revamped_plan_menu_items=$(launcher_revamped_menu_items)
  set -- display-menu -T Launchers
  while IFS= read -r launcher_revamped_plan_menu_line; do
    set -- "$@" "${launcher_revamped_plan_menu_line}"
  done <<EOF
${launcher_revamped_plan_menu_items}
EOF
  [ -n "${launcher_revamped_plan_menu_items}" ] || set -- display-menu -T Launchers
  launcher_revamped_bind "${launcher_revamped_plan_menu_key}" "Launcher menu" "$@"
}

launcher_revamped_plan_picker() {
  [ -n "${LAUNCHER_REVAMPED_S_picker_key}" ] || return 0
  launcher_revamped_plan_picker_then='\;'
  launcher_revamped_bind "${LAUNCHER_REVAMPED_S_picker_key}" "Pick an app" display-popup -E "${LAUNCHER_REVAMPED_TOOL} pick" "${launcher_revamped_plan_picker_then}" run-shell -b "TMUX_PANE=#{pane_id} ${LAUNCHER_REVAMPED_TOOL} launch-picked"
}

launcher_revamped_plan() {
  launcher_revamped_load "${LAUNCHER_REVAMPED_GLOBALS}"
  launcher_revamped_load_apps "${LAUNCHER_REVAMPED_S_apps}"
  launcher_revamped_read_version
  LAUNCHER_REVAMPED_NOTES=0
  ! launcher_revamped_version_ge "${LAUNCHER_REVAMPED_TMUX}" 3.1 || LAUNCHER_REVAMPED_NOTES=1
  launcher_revamped_plan_tool
  LAUNCHER_REVAMPED_PLAN=""
  set -f
  for launcher_revamped_plan_id in ${LAUNCHER_REVAMPED_S_apps}; do
    launcher_revamped_plan_app "${launcher_revamped_plan_id}"
  done
  set +f
  launcher_revamped_plan_menu
  launcher_revamped_plan_picker
}

launcher_revamped_send() {
  launcher_revamped_send_plan="$1"
  set --
  launcher_revamped_send_sep=""
  while IFS= read -r launcher_revamped_send_line; do
    if [ -z "${launcher_revamped_send_line}" ]; then
      [ "$#" -eq 0 ] || launcher_revamped_send_sep=";"
      continue
    fi
    [ -z "${launcher_revamped_send_sep}" ] || set -- "$@" "${launcher_revamped_send_sep}"
    launcher_revamped_send_sep=""
    [ "${launcher_revamped_send_line}" != "${LAUNCHER_REVAMPED_EMPTY}" ] || launcher_revamped_send_line=""
    set -- "$@" "${launcher_revamped_send_line}"
  done <<PLAN
${launcher_revamped_send_plan}
PLAN
  [ "$#" -gt 0 ] || return 0
  tmux "$@"
}

launcher_revamped_apply() {
  launcher_revamped_plan
  launcher_revamped_send "${LAUNCHER_REVAMPED_PLAN}" 2>/dev/null || launcher_revamped_apply_each
}

launcher_revamped_apply_each() {
  launcher_revamped_apply_each_status=0
  set --
  while IFS= read -r launcher_revamped_apply_each_line; do
    if [ "${launcher_revamped_apply_each_line}" = "${LAUNCHER_REVAMPED_EMPTY}" ]; then
      set -- "$@" ""
      continue
    fi
    if [ -n "${launcher_revamped_apply_each_line}" ]; then
      set -- "$@" "${launcher_revamped_apply_each_line}"
      continue
    fi
    [ "$#" -gt 0 ] || continue
    tmux "$@" || launcher_revamped_apply_each_status=1
    set --
  done <<PLAN
${LAUNCHER_REVAMPED_PLAN}
PLAN
  return "${launcher_revamped_apply_each_status}"
}

launcher_revamped_lines() {
  printf '%s' "${LAUNCHER_REVAMPED_PLAN}" | awk 'NF == 0 && line != "" { print line; line = ""; next } NF == 0 { next } { line = (line == "" ? $0 : line " " $0) } END { if (line != "") { print line } }'
}

launcher_revamped_json() {
  printf '%s' "${LAUNCHER_REVAMPED_PLAN}" | awk '
    function quote(s,    out, i, c) {
      out = ""
      for (i = 1; i <= length(s); i++) {
        c = substr(s, i, 1)
        if (c == "\\") { out = out "\\\\" } else if (c == "\"") { out = out "\\\"" } else { out = out c }
      }
      return "\"" out "\""
    }
    /^$/ { if (args != "") { rows = rows (rows == "" ? "" : ",") "[" args "]" } args = ""; next }
    { args = args (args == "" ? "" : ",") (($0 == "\047\047") ? "\"\"" : quote($0)) }
    END {
      if (args != "") { rows = rows (rows == "" ? "" : ",") "[" args "]" }
      print "{\"bindings\":[" rows "]}"
    }
  '
}

launcher_revamped_bindings() {
  printf '%s' "${LAUNCHER_REVAMPED_PLAN}" | awk 'previous == "" && $0 == "bind-key" { count++ } { previous = $0 } END { print count + 0 }'
}

launcher_revamped_setting_name() {
  launcher_revamped_setting_name_raw=$(printf '%s\n' "${1#--}" | tr '-' '_')
  case " ${LAUNCHER_REVAMPED_GLOBAL_NAMES} " in
  *" ${launcher_revamped_setting_name_raw} "*)
    printf '%s\n' "${launcher_revamped_setting_name_raw}"
    return 0
    ;;
  *) : ;;
  esac
  case "${launcher_revamped_setting_name_raw}:  ${LAUNCHER_REVAMPED_FIELDS} " in
  _*:* | *_:*) printf '\n' ;;
  *_*:*" ${launcher_revamped_setting_name_raw##*_} "*) printf '%s\n' "${launcher_revamped_setting_name_raw}" ;;
  *) printf '\n' ;;
  esac
}
