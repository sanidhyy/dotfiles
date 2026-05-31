#!/usr/bin/env bash
set -euo pipefail

log() { printf '%s\n' "$*"; }
warn() { printf 'WARN: %s\n' "$*" >&2; }
die() { printf 'ERROR: %s\n' "$*" >&2; exit 1; }

have() { command -v "$1" >/dev/null 2>&1; }

ts() { date +"%Y%m%d-%H%M%S"; }

sudo_prefix_for_dst() {
  # Return "sudo" if dst is outside $HOME, else empty.
  # This is intentionally conservative: /etc, /boot, /usr will require sudo.
  local dst="$1"
  if [[ "$dst" == "$HOME"* ]]; then
    return 1
  fi
  return 0
}

abspath_repo_root() {
  # install/lib.sh -> install/ -> repo root
  local script_dir
  script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
  (cd -- "${script_dir}/.." && pwd)
}

expand_vars() {
  # Expand $HOME in manifest paths.
  local s="$1"
  s="${s//\$HOME/$HOME}"
  printf '%s' "$s"
}

ensure_parent_dir() {
  local dst="$1"
  local parent
  parent="$(dirname -- "$dst")"
  if sudo_prefix_for_dst "$dst"; then
    sudo mkdir -p -- "$parent"
  else
    mkdir -p -- "$parent"
  fi
}

backup_existing_file() {
  # Only for files/symlinks.
  local dst="$1"
  local stamp="$2"
  local backup="${dst}.old.${stamp}"
  if sudo_prefix_for_dst "$dst"; then
    sudo mv -f -- "$dst" "$backup"
  else
    mv -f -- "$dst" "$backup"
  fi
  log "Backed up: $dst -> $backup"
}

link_file() {
  local src="$1"
  local dst="$2"

  ensure_parent_dir "$dst"

  if [[ -e "$dst" || -L "$dst" ]]; then
    # If it's already the desired symlink, do nothing.
    if [[ -L "$dst" ]]; then
      local cur
      cur="$(readlink -- "$dst" || true)"
      if [[ "$cur" == "$src" ]]; then
        return 0
      fi
    fi

    if [[ -f "$dst" || -L "$dst" ]]; then
      backup_existing_file "$dst" "$(ts)"
    else
      # Existing directory (should not happen if manifest maps files).
      warn "Destination is a directory, skipping: $dst"
      return 0
    fi
  fi

  if sudo_prefix_for_dst "$dst"; then
    sudo ln -nsf -- "$src" "$dst"
  else
    ln -nsf -- "$src" "$dst"
  fi
  log "Linked: $dst -> $src"
}

chmod_x_if_file() {
  local dst="$1"
  if [[ -f "$dst" || -L "$dst" ]]; then
    chmod +x -- "$dst" 2>/dev/null || true
  fi
}

copy_file() {
  local src="$1"
  local dst="$2"

  ensure_parent_dir "$dst"

  if [[ -e "$dst" || -L "$dst" ]]; then
    if [[ -f "$dst" || -L "$dst" ]]; then
      backup_existing_file "$dst" "$(ts)"
    else
      warn "Destination is a directory, skipping: $dst"
      return 0
    fi
  fi

  if sudo_prefix_for_dst "$dst"; then
    sudo cp -f -- "$src" "$dst"
  else
    cp -f -- "$src" "$dst"
  fi
  log "Copied: $src -> $dst"
}

glob_files() {
  # Print files for a glob relative to repo root.
  local repo_root="$1"
  local pattern="$2"

  # Enable ** support and empty-match behavior.
  shopt -s globstar nullglob dotglob
  local matches=()
  # shellcheck disable=SC2206
  matches=("$repo_root"/$pattern)
  shopt -u globstar nullglob dotglob

  local f
  for f in "${matches[@]}"; do
    [[ -f "$f" ]] && printf '%s\n' "$f"
  done
}

detect_timezone() {
  local tz=""
  if have timedatectl; then
    tz="$(timedatectl show -p Timezone --value 2>/dev/null || true)"
  fi
  if [[ -z "$tz" && -f /etc/timezone ]]; then
    tz="$(tr -d '\n' < /etc/timezone 2>/dev/null || true)"
  fi
  if [[ -z "$tz" && -L /etc/localtime ]]; then
    local target
    target="$(readlink -f /etc/localtime 2>/dev/null || true)"
    if [[ "$target" == */zoneinfo/* ]]; then
      tz="${target##*/zoneinfo/}"
    fi
  fi
  printf '%s' "$tz"
}

require_gum() {
  have gum || die "gum is required but not found in PATH."
}

maybe_warn_omarchy_version() {
  if have omarchy-version; then
    local v
    v="$(omarchy-version 2>/dev/null || true)"
    [[ -n "$v" ]] && log "Omarchy version: $v"
  else
    warn "omarchy-version not found; continuing anyway."
  fi
}

sudo_warmup_if_needed() {
  local needs_sudo="$1"
  if [[ "$needs_sudo" != "1" ]]; then
    return 0
  fi
  if ! have sudo; then
    warn "sudo not found; will skip any /etc or /boot installs."
    return 1
  fi
  if sudo -v; then
    return 0
  fi
  warn "sudo auth failed; will skip any /etc or /boot installs."
  return 1
}

hyprctl_json_supported() {
  have hyprctl || return 1
  hyprctl -j monitors >/dev/null 2>&1
}

hyprctl_list_monitors() {
  # Output connector names, one per line.
  if hyprctl_json_supported && have jq; then
    hyprctl -j monitors all 2>/dev/null | jq -r '.[].name' 2>/dev/null
    return 0
  fi

  # Fallback: parse text.
  hyprctl monitors all 2>/dev/null | awk '/^Monitor /{print $2}' || true
}

hyprctl_list_modes_for_monitor() {
  local monitor="$1"

  if hyprctl_json_supported && have jq; then
    # Try a few common field names across versions.
    hyprctl -j monitors all 2>/dev/null | jq -r --arg m "$monitor" '
      .[]
      | select(.name == $m)
      | (
          .availableModes? // .modes? // []
        )
      | .[]
    ' 2>/dev/null | sed 's/ (preferred)//g'
    return 0
  fi

  # Fallback: parse text section between "Monitor X" and next "Monitor".
  hyprctl monitors all 2>/dev/null \
    | awk -v mon="$monitor" '
      $1=="Monitor" && $2==mon {in=1; next}
      $1=="Monitor" {in=0}
      in && $0 ~ /availableModes:/ {modes=1; next}
      in && modes && $0 ~ /^[[:space:]]*[0-9]/ {gsub(/^[[:space:]]+/, ""); print; next}
      in && modes && $0 !~ /^[[:space:]]*[0-9]/ && $0 !~ /^[[:space:]]*$/ {modes=0}
    ' \
    | sed 's/ (preferred)//g' \
    || true
}

