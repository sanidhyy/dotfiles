#!/usr/bin/env bash
# Stow user packages from this repo (never system/, extras/, or meta dirs).
set -euo pipefail

cd "$(dirname "$(readlink -f "$0")")"

exclude='^(system|\.git|\.github|\.cursor|extras)$'

usage() {
  cat <<'EOF'
Usage: ./stow.sh [stow-flags] [package...]

  ./stow.sh              stow every user package
  ./stow.sh hypr waybar  stow selected packages
  ./stow.sh -R           restow all
  ./stow.sh -D hypr      unstow one package
  ./stow.sh -n           dry-run (no links created)
  ./stow.sh -h, --help   show this help

Install Stow first:
  Arch Linux:       sudo pacman -S stow
  Debian / Ubuntu:  sudo apt install stow
  Fedora:           sudo dnf install stow
EOF
}

user_packages() {
  find . -mindepth 1 -maxdepth 1 -type d -printf '%f\n' \
    | grep -Ev "$exclude" \
    | sort
}

flags=()
packages=()
for arg in "$@"; do
  case "$arg" in
    -h|--help)
      usage
      exit 0
      ;;
    -*) flags+=("$arg") ;;
    system)
      echo "Refusing to stow 'system'. Copy those files into /boot, /etc, and /usr manually (see README)." >&2
      exit 1
      ;;
    extras)
      echo "Refusing to stow 'extras'. Copy wallpapers into ~/.config/omarchy/backgrounds/<current-theme>/ if you want them." >&2
      exit 1
      ;;
    *) packages+=("$arg") ;;
  esac
done

if ! command -v stow >/dev/null 2>&1; then
  echo "stow is not installed." >&2
  echo "  Arch Linux:       sudo pacman -S stow" >&2
  echo "  Debian / Ubuntu:  sudo apt install stow" >&2
  echo "  Fedora:           sudo dnf install stow" >&2
  exit 1
fi

if ((${#packages[@]} == 0)); then
  mapfile -t packages < <(user_packages)
fi

cmd=(stow -t "$HOME")
((${#flags[@]})) && cmd+=("${flags[@]}")
cmd+=("${packages[@]}")
exec "${cmd[@]}"
