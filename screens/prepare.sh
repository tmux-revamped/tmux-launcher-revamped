#!/bin/sh
set -eu

: "${SCREENS_REPO:?}"
demo=/Users/Shared/demo
rm -rf "${demo}"
mkdir -p "${demo}/home" "${demo}/bin" "${demo}/project/src"
tmux_path=$(command -v tmux)
ln -s "${tmux_path}" "${demo}/bin/tmux"
lazygit_version=$(lazygit --version 2>/dev/null | sed -n 's/.*[ ,]version=\([^,]*\),.*/\1/p')
mkdir -p "${demo}/tmux-launcher-revamped"
cp -Rpf "${SCREENS_REPO}/bin" "${SCREENS_REPO}/lib" "${SCREENS_REPO}/launcher-revamped.tmux" "${demo}/tmux-launcher-revamped/"
for lazygit_dir in "${demo}/home/Library/Application Support/lazygit" "${demo}/home/.config/lazygit"; do
  mkdir -p "${lazygit_dir}"
  printf 'update:\n  method: never\n' >"${lazygit_dir}/config.yml"
  printf 'startuppopupversion: 99\nlastversion: %s\n' "${lazygit_version}" >"${lazygit_dir}/state.yml"
done
cd "${demo}/project"
printf '# project\n\nA demo project for the launcher screens.\n' >README.md
printf 'print("hello")\n' >src/main.py
git init -q -b main
git -c user.name=octocat -c user.email= add README.md src/main.py
GIT_AUTHOR_DATE=2026-01-01T12:00:00Z GIT_COMMITTER_DATE=2026-01-01T12:00:00Z git -c user.name=octocat -c user.email= commit -q -m "feat: start the project"
printf '\nRun it with python3 src/main.py.\n' >>README.md
