# shellcheck shell=bash
# shellcheck disable=SC2207

_launcher_revamped() {
  local cur prev
  cur="${COMP_WORDS[COMP_CWORD]}"
  prev="${COMP_WORDS[COMP_CWORD - 1]}"

  case "${prev}" in
  --theme)
    COMPREPLY=($(compgen -W "kodougu catppuccin-mocha catppuccin-latte dracula nord gruvbox tokyo-night mono" -- "${cur}"))
    return
    ;;
  --skip-missing)
    COMPREPLY=($(compgen -W "on off" -- "${cur}"))
    return
    ;;
  --apps | --menu-key | --picker-key | --marker | --max-depth)
    return
    ;;
  *) ;;
  esac

  COMPREPLY=($(compgen -W "apply list launch pick launch-picked doctor version help --json --theme --apps --menu-key --picker-key --marker --max-depth --skip-missing" -- "${cur}"))
}

complete -F _launcher_revamped launcher-revamped
