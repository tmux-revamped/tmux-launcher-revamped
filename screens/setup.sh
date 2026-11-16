export PS1='$ '
export PATH="/Users/Shared/demo/tmux-launcher-revamped/bin:${PATH}"
export TZ=UTC
unset KODOUGU_THEME KODOUGU_ACCENT LAUNCHER_REVAMPED_THEME LAUNCHER_REVAMPED_ACCENT NO_COLOR
export HOME=/Users/Shared/demo/home
cd /Users/Shared/demo/project/src || return 1
printf '\033]2;demo\033\134'
clear
