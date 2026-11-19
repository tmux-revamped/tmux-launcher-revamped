#!/bin/sh
# shellcheck disable=SC2034

[ -n "${LAUNCHER_REVAMPED_STATE_LOADED:-}" ] && return 0
LAUNCHER_REVAMPED_STATE_LOADED=1

LAUNCHER_REVAMPED_GLOBALS='apps	lazygit yazi
menu_key	M-a
picker_key
marker
max_depth	20
skip_missing	off'
LAUNCHER_REVAMPED_GLOBAL_NAMES='apps menu_key picker_key marker max_depth skip_missing'
LAUNCHER_REVAMPED_FIELDS='key command mode name width height marker if prompt group host reuse env pre exit'
LAUNCHER_REVAMPED_S_apps='lazygit yazi'
LAUNCHER_REVAMPED_S_menu_key='M-a'
LAUNCHER_REVAMPED_S_picker_key=''
LAUNCHER_REVAMPED_S_marker=''
LAUNCHER_REVAMPED_S_max_depth='20'
LAUNCHER_REVAMPED_S_skip_missing='off'
LAUNCHER_REVAMPED_TYPED=@launcher_revamped_typed
LAUNCHER_REVAMPED_PICKED=@launcher_revamped_picked
LAUNCHER_REVAMPED_PLAN=""
LAUNCHER_REVAMPED_EMPTY="''"
LAUNCHER_REVAMPED_TMUX=""
LAUNCHER_REVAMPED_NOTES=0
LAUNCHER_REVAMPED_TOOL=""
LAUNCHER_REVAMPED_VALUE=""
LAUNCHER_REVAMPED_PATH=""
LAUNCHER_REVAMPED_MENU_TAKEN=""
REVAMPED_LOG_NS=launcher-revamped
LAUNCHER_REVAMPED_KINDS='max_depth	number
skip_missing	on off'
LAUNCHER_REVAMPED_MODES='popup window split'
