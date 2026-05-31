#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=install/lib.sh
source "$SCRIPT_DIR/lib.sh"

REPO_ROOT="$(abspath_repo_root)"
MANIFEST_PATH="$REPO_ROOT/install/manifest.json"

INSTALL_CSV=""
SKIP_CSV=""
MONITOR_MODE=""
EXT_MONITOR=""
EXT_MODE=""
INT_MONITOR=""
INT_MODE=""
TIMEZONE=""
ENABLE_SERVICES="0"
INSTALL_DEPS="0"
INSTALL_TRASH="0"
INSTALL_THEME="0"

usage() {
  cat <<'EOF'
Usage:
  install/install.sh                # interactive (gum)
  install/install.sh --install a,b  # non-interactive

Flags:
  --install <csv>         Comma-separated groups to install
  --skip <csv>            Comma-separated groups to skip (applied after --install)
  --monitor-mode <single|dual>
  --ext-monitor <name>    External connector name
  --ext-mode <mode>       Mode like 1920x1080@180.00
  --int-monitor <name>    Internal connector name
  --int-mode <mode>       Mode like 1920x1200@120.00
  --timezone <tz>         Timezone like Asia/Kolkata (auto-detected if omitted)
  --enable-services       Enable selected systemd --user units now
  --install-deps          Install required packages using yay
  --install-trash         Install trash-cli using yay (separate prompt/step)
  --install-theme         Install Catppuccin Mocha Omarchy theme
  -h, --help              Show help
EOF
}

csv_has() {
  local csv="$1" item="$2"
  [[ ",$csv," == *",$item,"* ]]
}

csv_add() {
  local csv="$1" item="$2"
  if [[ -z "$csv" ]]; then
    printf '%s' "$item"
    return 0
  fi
  if csv_has "$csv" "$item"; then
    printf '%s' "$csv"
    return 0
  fi
  printf '%s' "${csv},${item}"
}

py_groups() {
  python3 - <<'PY' "$MANIFEST_PATH"
import json, sys
path = sys.argv[1]
data = json.load(open(path, "r", encoding="utf-8"))
groups = data.get("groups", {})
for k in sorted(groups.keys()):
  g = groups[k]
  label = g.get("label", k)
  default = "1" if g.get("default") else "0"
  requires_sudo = "1" if g.get("requires_sudo") else "0"
  print(f"{k}\t{label}\t{default}\t{requires_sudo}")
PY
}

py_group_requires_sudo() {
  python3 - <<'PY' "$MANIFEST_PATH" "$1"
import json, sys
path, key = sys.argv[1], sys.argv[2]
data = json.load(open(path, "r", encoding="utf-8"))
g = data.get("groups", {}).get(key, {})
print("1" if g.get("requires_sudo") else "0")
PY
}

py_group_mappings() {
  # Print "src<TAB>dst" for mappings.
  python3 - <<'PY' "$MANIFEST_PATH" "$1"
import json, sys
path, key = sys.argv[1], sys.argv[2]
data = json.load(open(path, "r", encoding="utf-8"))
g = data.get("groups", {}).get(key, {})
for m in g.get("mappings", []):
  print(f"{m['src']}\t{m['dst']}")
PY
}

py_group_globs() {
  # Print "src_glob<TAB>dst_dir" for globs.
  python3 - <<'PY' "$MANIFEST_PATH" "$1"
import json, sys
path, key = sys.argv[1], sys.argv[2]
data = json.load(open(path, "r", encoding="utf-8"))
g = data.get("groups", {}).get(key, {})
for gg in g.get("globs", []):
  print(f"{gg['src_glob']}\t{gg['dst_dir']}")
PY
}

glob_prefix() {
  # Strip from first wildcard.
  local pattern="$1"
  local p="${pattern%%[*?]*}"
  printf '%s' "$p"
}

install_group() {
  local group="$1"

  while IFS=$'\t' read -r src_rel dst_raw; do
    [[ -z "${src_rel:-}" ]] && continue
    local src="$REPO_ROOT/$src_rel"
    local dst
    dst="$(expand_vars "$dst_raw")"
    if [[ ! -f "$src" ]]; then
      warn "Missing source file, skipping: $src_rel"
      continue
    fi
    if [[ "$group" == "boot" ]]; then
      copy_file "$src" "$dst"
    else
      link_file "$src" "$dst"
    fi
  done < <(py_group_mappings "$group" || true)

  while IFS=$'\t' read -r src_glob dst_dir_raw; do
    [[ -z "${src_glob:-}" ]] && continue
    local dst_dir
    dst_dir="$(expand_vars "$dst_dir_raw")"
    local prefix rel base rel_under dst
    prefix="$(glob_prefix "$src_glob")"
    base="${prefix%/}/"

    local f abs rel_path
    while IFS= read -r abs; do
      rel_path="${abs#$REPO_ROOT/}"
      rel_under="${rel_path#"$base"}"
      dst="${dst_dir%/}/$rel_under"
      if [[ "$group" == "extras_backgrounds" || "$group" == "boot" ]]; then
        copy_file "$abs" "$dst"
      else
        link_file "$abs" "$dst"
      fi
    done < <(glob_files "$REPO_ROOT" "$src_glob" || true)
  done < <(py_group_globs "$group" || true)
}

write_monitors_generated() {
  local mode="$1"

  # Decide monitor set.
  local out_hypr="$HOME/.config/hypr/monitors.generated.conf"
  local out_env="$HOME/.config/omarchy-custom/constants/monitors.env"
  mkdir -p "$HOME/.config/hypr" "$HOME/.config/omarchy-custom/constants"

  if [[ -z "$MONITOR_MODE" ]]; then
    MONITOR_MODE="$mode"
  fi

  if [[ "$MONITOR_MODE" == "single" ]]; then
    [[ -z "$EXT_MONITOR" ]] && return 0
    [[ -z "$EXT_MODE" ]] && return 0
    cat >"$out_hypr" <<EOF
monitor = ${EXT_MONITOR}, ${EXT_MODE}, auto, 1
EOF
    cat >"$out_env" <<EOF
export EXT_MONITOR="${EXT_MONITOR}"
export EXT_MONITOR_MODE="${EXT_MODE},auto,1"
EOF
    return 0
  fi

  if [[ "$MONITOR_MODE" == "dual" ]]; then
    [[ -z "$EXT_MONITOR" || -z "$EXT_MODE" || -z "$INT_MONITOR" || -z "$INT_MODE" ]] && return 0
    cat >"$out_hypr" <<EOF
monitor = ${EXT_MONITOR}, ${EXT_MODE}, auto, 1
monitor = ${INT_MONITOR}, ${INT_MODE}, auto, 1
EOF
    cat >"$out_env" <<EOF
export EXT_MONITOR="${EXT_MONITOR}"
export EXT_MONITOR_MODE="${EXT_MODE},auto,1"
export INT_MONITOR="${INT_MONITOR}"
export INT_MONITOR_MODE="${INT_MODE},auto,1"
EOF
  fi
}

interactive_collect_monitors() {
  local selected="$1"
  csv_has "$selected" "hypr" || return 0

  have hyprctl || { warn "hyprctl not found; skipping monitor auto-detect."; return 0; }

  local monitors
  monitors="$(hyprctl_list_monitors | sed '/^\s*$/d' || true)"
  [[ -z "$monitors" ]] && { warn "No monitors detected from hyprctl; skipping."; return 0; }

  MONITOR_MODE="$(printf "single\ndual\n" | gum choose --header "Monitor setup")"

  if [[ "$MONITOR_MODE" == "single" ]]; then
    EXT_MONITOR="$(printf '%s\n' "$monitors" | gum choose --header "Select monitor")"
    local modes
    modes="$(hyprctl_list_modes_for_monitor "$EXT_MONITOR" | sed '/^\s*$/d' || true)"
    [[ -z "$modes" ]] && { warn "No modes detected for $EXT_MONITOR; skipping."; return 0; }
    EXT_MODE="$(printf '%s\n' "$modes" | gum choose --header "Select mode for $EXT_MONITOR")"
    return 0
  fi

  if [[ "$MONITOR_MODE" == "dual" ]]; then
    INT_MONITOR="$(printf '%s\n' "$monitors" | gum choose --header "Select internal monitor")"
    EXT_MONITOR="$(printf '%s\n' "$monitors" | gum choose --header "Select external monitor")"
    local int_modes ext_modes
    int_modes="$(hyprctl_list_modes_for_monitor "$INT_MONITOR" | sed '/^\s*$/d' || true)"
    ext_modes="$(hyprctl_list_modes_for_monitor "$EXT_MONITOR" | sed '/^\s*$/d' || true)"
    [[ -n "$int_modes" ]] && INT_MODE="$(printf '%s\n' "$int_modes" | gum choose --header "Select mode for $INT_MONITOR")"
    [[ -n "$ext_modes" ]] && EXT_MODE="$(printf '%s\n' "$ext_modes" | gum choose --header "Select mode for $EXT_MONITOR")"
  fi
}

interactive_collect_timezone() {
  local selected="$1"
  csv_has "$selected" "windows" || return 0

  local detected
  detected="$(detect_timezone)"
  TIMEZONE="${TIMEZONE:-$detected}"
  TIMEZONE="$(gum input --prompt "Timezone: " --value "${TIMEZONE:-}" --placeholder "Asia/Kolkata")"
}

write_windows_env() {
  csv_has "$1" "windows" || return 0
  local tz="${TIMEZONE:-}"
  [[ -z "$tz" ]] && tz="$(detect_timezone)"
  [[ -z "$tz" ]] && tz="Asia/Kolkata"

  local env_path="$HOME/.config/omarchy-custom/windows/.env"
  mkdir -p -- "$(dirname -- "$env_path")"
  cat >"$env_path" <<EOF
TZ=${tz}
EOF
  log "Wrote: $env_path"
}

enable_systemd_user_units() {
  local selected="$1"
  [[ "$ENABLE_SERVICES" == "1" ]] || return 0
  csv_has "$selected" "systemd_user_services" || return 0

  have systemctl || { warn "systemctl not found; skipping enable --user."; return 0; }

  local units_dir="$HOME/.config/systemd/user"
  [[ -d "$units_dir" ]] || return 0

  local unit
  while IFS= read -r unit; do
    [[ -z "$unit" ]] && continue
    systemctl --user enable --now "$(basename -- "$unit")" || warn "Failed enabling: $(basename -- "$unit")"
  done < <(find "$units_dir" -maxdepth 1 -type f \( -name '*.service' -o -name '*.timer' \) 2>/dev/null || true)
}

install_deps_with_yay() {
  local selected="$1"
  [[ "$INSTALL_DEPS" == "1" ]] || return 0

  have yay || { warn "yay not found; skipping dependency install."; return 0; }

  local pkgs=()

  # Waybar GPU module
  if csv_has "$selected" "waybar" && ! have gpu-usage-waybar; then
    pkgs+=("gpu-usage-waybar-git")
  fi

  # Common helper tools used by scripts/modules (assume core stack is installed).
  # Waybar privacydots + other scripts need jq, pw-dump (pipewire), fuser (psmisc).
  if csv_has "$selected" "waybar"; then
    have jq || pkgs+=("jq")
    have pw-dump || pkgs+=("pipewire")
    have fuser || pkgs+=("psmisc")
    have cava || pkgs+=("cava")
    have playerctl || pkgs+=("playerctl")
  fi

  # Live wallpaper/thumb generation helpers used by omarchy-custom theme background scripts.
  # These can be relevant when installing backgrounds or the scripts themselves.
  if csv_has "$selected" "extras_backgrounds" || csv_has "$selected" "bin"; then
    have mpvpaper || pkgs+=("mpvpaper")
    have ffmpegthumbnailer || pkgs+=("ffmpegthumbnailer")
  fi

  # Trash management (kept as separate explicit step/flag).
  if [[ "$INSTALL_TRASH" == "1" ]]; then
    have trash-empty || pkgs+=("trash-cli")
  fi

  ((${#pkgs[@]})) || return 0

  # De-dupe packages while preserving order.
  local uniq=()
  local p
  for p in "${pkgs[@]}"; do
    if [[ " ${uniq[*]} " != *" $p "* ]]; then
      uniq+=("$p")
    fi
  done

  log "Installing packages with yay: ${uniq[*]}"
  yay -S --noconfirm --needed "${uniq[@]}"
}

post_install_fix_perms() {
  local selected="$1"

  if csv_has "$selected" "bin" && [[ -d "$HOME/.local/bin" ]]; then
    chmod -R +x "$HOME/.local/bin" 2>/dev/null || true
  fi
  if csv_has "$selected" "waybar" && [[ -d "$HOME/.config/waybar/scripts" ]]; then
    chmod -R +x "$HOME/.config/waybar/scripts" 2>/dev/null || true
  fi
  if csv_has "$selected" "omarchy" && [[ -d "$HOME/.config/omarchy/hooks" ]]; then
    chmod -R +x "$HOME/.config/omarchy/hooks" 2>/dev/null || true
  fi
}

post_install_boot_limine() {
  local selected="$1"
  csv_has "$selected" "boot" || return 0
  have limine-mkinitcpio || { warn "limine-mkinitcpio not found; skipping generation."; return 0; }
  have sudo || { warn "sudo not found; cannot run limine-mkinitcpio."; return 0; }
  sudo limine-mkinitcpio || warn "limine-mkinitcpio failed."
}

maybe_install_theme() {
  [[ "$INSTALL_THEME" == "1" ]] || return 0
  have omarchy-theme-install || { warn "omarchy-theme-install not found; skipping theme install."; return 0; }

  local url="https://github.com/sanidhyy/omarchy-catppuccin-mocha-theme"
  log "Installing Omarchy theme: $url"
  omarchy-theme-install "$url" || warn "Theme install failed."

  if have omarchy-plymouth-set-by-theme; then
    omarchy-plymouth-set-by-theme set catppuccin-mocha || warn "omarchy-plymouth-set-by-theme set failed."
  else
    warn "omarchy-plymouth-set-by-theme not found; skipping plymouth theme set."
  fi
}

parse_args() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --install) INSTALL_CSV="${2:-}"; shift 2 ;;
      --skip) SKIP_CSV="${2:-}"; shift 2 ;;
      --monitor-mode) MONITOR_MODE="${2:-}"; shift 2 ;;
      --ext-monitor) EXT_MONITOR="${2:-}"; shift 2 ;;
      --ext-mode) EXT_MODE="${2:-}"; shift 2 ;;
      --int-monitor) INT_MONITOR="${2:-}"; shift 2 ;;
      --int-mode) INT_MODE="${2:-}"; shift 2 ;;
      --timezone) TIMEZONE="${2:-}"; shift 2 ;;
      --enable-services) ENABLE_SERVICES="1"; shift ;;
      --install-deps) INSTALL_DEPS="1"; shift ;;
      --install-trash) INSTALL_TRASH="1"; shift ;;
      --install-theme) INSTALL_THEME="1"; shift ;;
      -h|--help) usage; exit 0 ;;
      *) die "Unknown arg: $1" ;;
    esac
  done
}

interactive_select_groups() {
  require_gum

  local items=() defaults=() labels=() line key label def req
  while IFS=$'\t' read -r key label def req; do
    items+=("$key")
    labels+=("$key - $label")
    [[ "$def" == "1" ]] && defaults+=("$key - $label")
  done < <(py_groups)

  local selected_labels
  if gum choose --help 2>&1 | grep -q -- '--selected'; then
    selected_labels="$(printf '%s\n' "${labels[@]}" | gum choose --no-limit --selected "$(printf '%s,' "${defaults[@]}" | sed 's/,$//')" --header "Select config groups")"
  else
    selected_labels="$(printf '%s\n' "${labels[@]}" | gum choose --no-limit --header "Select config groups")"
  fi

  local selected=""
  local l
  while IFS= read -r l; do
    [[ -z "$l" ]] && continue
    selected="$(csv_add "$selected" "${l%% *}")"
  done <<<"$selected_labels"

  printf '%s' "$selected"
}

main() {
  parse_args "$@"

  [[ -f "$MANIFEST_PATH" ]] || die "Manifest not found: $MANIFEST_PATH"

  maybe_warn_omarchy_version

  if [[ -z "$INSTALL_CSV" ]]; then
    require_gum
    gum confirm "Install Catppuccin Mocha Omarchy theme?" && INSTALL_THEME="1" || true
  fi

  local selected=""
  local interactive="1"
  if [[ -n "$INSTALL_CSV" ]]; then
    interactive="0"
    selected="$INSTALL_CSV"
  else
    selected="$(interactive_select_groups)"
  fi

  # Apply skips.
  if [[ -n "$SKIP_CSV" ]]; then
    local out=""
    IFS=',' read -ra parts <<<"$selected"
    local p
    for p in "${parts[@]}"; do
      [[ -z "$p" ]] && continue
      csv_has "$SKIP_CSV" "$p" && continue
      out="$(csv_add "$out" "$p")"
    done
    selected="$out"
  fi

  # Sudo warmup if any selected group requires sudo.
  local needs_sudo="0"
  IFS=',' read -ra sel_parts <<<"$selected"
  local g
  for g in "${sel_parts[@]}"; do
    [[ -z "$g" ]] && continue
    [[ "$(py_group_requires_sudo "$g")" == "1" ]] && needs_sudo="1"
  done
  local sudo_ok="1"
  if [[ "$needs_sudo" == "1" ]]; then
    if ! sudo_warmup_if_needed "1"; then
      sudo_ok="0"
    fi
  fi

  # If sudo isn't OK, drop sudo groups.
  if [[ "$sudo_ok" == "0" ]]; then
    local out=""
    for g in "${sel_parts[@]}"; do
      [[ -z "$g" ]] && continue
      [[ "$(py_group_requires_sudo "$g")" == "1" ]] && continue
      out="$(csv_add "$out" "$g")"
    done
    selected="$out"
  fi

  if [[ "$interactive" == "1" ]]; then
    interactive_collect_monitors "$selected"
    interactive_collect_timezone "$selected"
  fi

  if [[ "$interactive" == "1" && "$INSTALL_DEPS" == "0" ]]; then
    local needs_prompt="0"

    if csv_has "$selected" "waybar"; then
      if ! have gpu-usage-waybar || ! have jq || ! have pw-dump || ! have fuser || ! have cava || ! have playerctl; then
        needs_prompt="1"
      fi
    fi

    if csv_has "$selected" "extras_backgrounds" || csv_has "$selected" "bin"; then
      if ! have mpvpaper || ! have ffmpegthumbnailer; then
        needs_prompt="1"
      fi
    fi

    if [[ "$needs_prompt" == "1" ]]; then
      if have yay; then
        gum confirm "Install missing package dependencies using yay?" && INSTALL_DEPS="1" || true
      else
        warn "Some dependencies are missing and yay is not installed."
      fi
    fi
  fi

  if [[ "$interactive" == "1" && "$INSTALL_TRASH" == "0" ]]; then
    if (csv_has "$selected" "shell" || csv_has "$selected" "systemd_user_services") && ! have trash-empty; then
      if have yay; then
        gum confirm "Install trash-cli (provides trash-empty) using yay?" && INSTALL_TRASH="1" || true
      else
        warn "trash-empty is missing and yay is not installed."
      fi
    fi
  fi

  install_deps_with_yay "$selected"

  maybe_install_theme

  log "Installing groups: $selected"

  # Install selected groups.
  IFS=',' read -ra sel_parts2 <<<"$selected"
  for g in "${sel_parts2[@]}"; do
    [[ -z "$g" ]] && continue
    install_group "$g"
  done

  # Generated local files for monitors/timezone.
  write_monitors_generated "${MONITOR_MODE:-}"
  write_windows_env "$selected"
  enable_systemd_user_units "$selected"
  post_install_fix_perms "$selected"
  post_install_boot_limine "$selected"

  log "Done."
}

main "$@"
