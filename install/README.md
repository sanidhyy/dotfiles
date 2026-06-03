# Dotfiles installer

Install Hyprland, Waybar, Omarchy hooks, and the rest of this repo onto your machine. The script reads **`install/manifest.json`**, lets you pick **groups** (components), then symlinks or copies files into place.

> **New here?** Clone the repo, run the installer, follow the prompts. The sections below go deeper only if you need them.

---

## Table of contents

1. [Quick start](#quick-start)
2. [Before you install](#before-you-install)
3. [How it works](#how-it-works)
4. [Interactive vs CLI](#interactive-vs-cli)
5. [What you can install](#what-you-can-install)
6. [Common commands](#common-commands)
7. [After install](#after-install)
8. [Troubleshooting](#troubleshooting)
9. [Technical reference](#technical-reference) — manifest, `lib.sh`, extending

---

## Quick start

```bash
git clone https://github.com/sanidhyy/dotfiles.git
cd dotfiles/install
chmod +x install.sh
./install.sh
```

The script will ask which components to install (via **gum**), optionally set up monitors, theme, and extra packages.

**Files involved**

| File                    | Role                                     |
| ----------------------- | ---------------------------------------- |
| `install/install.sh`    | Entry point — CLI and interactive flow   |
| `install/lib.sh`        | Symlinks, copies, backups, sudo helpers  |
| `install/manifest.json` | List of install groups and file mappings |

---

## Before you install

| Requirement                                     | When                                                                              |
| ----------------------------------------------- | --------------------------------------------------------------------------------- |
| **[gum](https://github.com/charmbracelet/gum)** | Interactive mode (default). Use `--install` if you prefer not to install gum.     |
| **python3**                                     | Reading `manifest.json`                                                           |
| **Hyprland + `hyprctl`**                        | Monitor prompts when installing `hypr` (or pass `--monitor-mode` / monitor flags) |
| **[yay](https://github.com/Jguer/yay)**         | Only if you accept optional dependency installs                                   |
| **Omarchy**                                     | Theme install (`omarchy-theme-install`) and some hooks                            |

Back up configs you care about. Existing files are renamed to `*.old.<timestamp>` before being replaced.

---

## How it works

```mermaid
flowchart LR
  A[Pick groups] --> B[Optional deps / theme]
  B --> C[Install files]
  C --> D[Generated configs]
  D --> E[Post-install hooks]
```

1. **Select groups** — from the manifest (interactive multi-select or `--install`).
2. **Optional extras** — Catppuccin Mocha theme, `yay` packages, timezone for Windows VM.
3. **Install files** — each group maps repo paths → your home (symlink) or system paths (copy).
4. **Generate** — monitor lines for Hyprland, `.env` for Windows VM when relevant.
5. **Finish** — chmod scripts, optional `systemctl --user enable`, Limine hook for `boot`.

**Symlink vs copy**

- **`$HOME`** configs → symlinks (edits in the repo show up after `git pull`).
- **`/etc`, `/usr`, `/boot`** → real copies (need sudo).
- **Wallpapers** (`extras_backgrounds`) → copied flat into `~/Wallpapers`.

---

## Interactive vs CLI

### Interactive (recommended)

Run with no flags:

```bash
./install/install.sh
```

You’ll be guided through:

- Theme install (Catppuccin Mocha)
- Which groups to install (defaults pre-selected)
- Monitor layout if **Hyprland** is selected
- Timezone if **Windows VM** config is selected
- Optional `yay` installs (Waybar deps, wallpapers, `trash-cli`)

### Non-interactive

Pass a comma-separated list of group keys:

```bash
./install/install.sh --install hypr,waybar,kitty,starship,gtk,fastfetch,bin,omarchy
```

Useful flags:

| Flag                                                         | Purpose                                 |
| ------------------------------------------------------------ | --------------------------------------- |
| `--skip a,b`                                                 | Remove keys from a `--install` list     |
| `--install-theme`                                            | Install Catppuccin Mocha Omarchy theme  |
| `--install-deps`                                             | Install missing packages via `yay`      |
| `--install-trash`                                            | Install `trash-cli`                     |
| `--enable-services`                                          | Enable user systemd units after install |
| `--monitor-mode single\|dual`                                | Skip monitor prompts                    |
| `--ext-monitor`, `--ext-mode`, `--int-monitor`, `--int-mode` | Monitor wiring (with `hypr`)            |
| `--timezone Region/City`                                     | For `windows` group `.env`              |

Run `./install/install.sh --help` for the full list.

---

## What you can install

Groups are defined in **`install/manifest.json`**. Keys below match the manifest; labels in the installer are human-readable versions of the same thing.

### Selected by default

| Key              | What it installs                         |
| ---------------- | ---------------------------------------- |
| `hypr`           | Hyprland configs under `~/.config/hypr/` |
| `waybar`         | Waybar config, styles, scripts           |
| `kitty`          | Kitty terminal                           |
| `starship`       | Shell prompt                             |
| `gtk`            | GTK 3 styling                            |
| `fastfetch`      | Terminal splash                          |
| `bin`            | Scripts in `~/.local/bin/`               |
| `omarchy_custom` | Omarchy custom constants                 |
| `elephant`       | Elephant wallpaper menu                  |
| `omarchy`        | Omarchy hooks and extensions             |

### Optional (home directory)

| Key                     | What it installs                                 |
| ----------------------- | ------------------------------------------------ |
| `btop`                  | Resource monitor                                 |
| `swayosd`               | Volume / brightness OSD                          |
| `gamemode`              | GameMode config                                  |
| `shell`                 | `~/.bashrc`                                      |
| `systemd_user_services` | User systemd units                               |
| `extras_backgrounds`    | Wallpapers → `~/Wallpapers/` (copy)              |
| `windows`               | Docker Compose for Windows VM + generated `.env` |

### System-level (requires sudo)

| Key    | What it installs                                              |
| ------ | ------------------------------------------------------------- |
| `etc`  | Files under `/etc/`                                           |
| `boot` | Boot-related files (e.g. Limine); may run `limine-mkinitcpio` |
| `usr`  | e.g. SDDM theme under `/usr/`                                 |

If sudo fails at startup, sudo groups are skipped and home groups still install.

Missing optional sources (e.g. a large image not in git) log a warning and continue.

---

## Common commands

**Full desktop stack with theme and dependencies**

```bash
./install/install.sh \
  --install hypr,waybar,kitty,starship,gtk,fastfetch,bin,omarchy,omarchy_custom,elephant \
  --install-theme --install-deps
```

**Dual monitors (non-interactive)**

```bash
./install/install.sh --install hypr,waybar \
  --monitor-mode dual \
  --ext-monitor HDMI-A-1 --ext-mode "1920x1080@60.00" \
  --int-monitor eDP-1 --int-mode "1920x1200@120.00"
```

**System configs + enable timers**

```bash
./install/install.sh --install etc,boot,usr --enable-services
```

**Exclude one group from a list**

```bash
./install/install.sh --install hypr,waybar,extras_backgrounds --skip extras_backgrounds
```

---

## After install

### Generated files (not in git)

When **hypr** is installed with monitor settings:

| File                                              | Purpose                          |
| ------------------------------------------------- | -------------------------------- |
| `~/.config/hypr/monitors.generated.conf`          | `monitor = …` lines for Hyprland |
| `~/.config/omarchy-custom/constants/monitors.env` | `EXT_MONITOR`, modes, etc.       |

Repo `hypr/monitors.conf` sources the generated file:

```conf
source = ~/.config/hypr/monitors.generated.conf
```

When **windows** is installed:

- `~/.config/omarchy-custom/windows/.env` — `TZ=` from prompt, `--timezone`, or auto-detect.

### Optional systemd units

If you installed `systemd_user_services`:

| Unit                                       | Purpose                                   |
| ------------------------------------------ | ----------------------------------------- |
| `mpvpaper-restart.timer`                   | Restart live wallpaper pipeline           |
| `trash-cleanup.timer`                      | Empty trash older than 30 days            |
| `rclone-gdrive.service`                    | Drive sync (needs your own rclone config) |
| `omarchy-recover-internal-monitor.service` | Monitor recovery helper                   |

```bash
systemctl --user enable --now mpvpaper-restart.timer
```

Or use `--enable-services` during install.

### Dependencies (`--install-deps`)

Installed via `yay` only when binaries are missing:

| Trigger                       | Packages                                                                |
| ----------------------------- | ----------------------------------------------------------------------- |
| `waybar`                      | `gpu-usage-waybar-git`, `jq`, `pipewire`, `psmisc`, `cava`, `playerctl` |
| `extras_backgrounds` or `bin` | `mpvpaper`, `ffmpegthumbnailer`                                         |
| `--install-trash`             | `trash-cli`                                                             |

---

## Troubleshooting

| Symptom                              | What to try                                                                                |
| ------------------------------------ | ------------------------------------------------------------------------------------------ |
| `gum is required`                    | Install gum, or use `--install …`                                                          |
| Monitor step skipped                 | Not in Hyprland: use `--monitor-mode` and monitor flags, or edit `monitors.generated.conf` |
| Sudo groups skipped                  | Fix `sudo -v`, or install home-only groups                                                 |
| `Missing source file`                | Optional asset missing from repo — add locally or ignore                                   |
| Waybar GPU module empty              | `--install-deps` or install `gpu-usage-waybar-git`                                         |
| Theme install failed                 | Install Omarchy tooling; install theme from the theme repo manually                        |
| `fastfetch/hatsune-miku.png` missing | Add image locally or ignore the warning                                                    |

At startup the script logs `omarchy-version` when available; configs may expect a recent Omarchy release.

---

## Technical reference

<details>
<summary><strong>Repository layout</strong></summary>

| Path                    | Role                                                     |
| ----------------------- | -------------------------------------------------------- |
| `install/install.sh`    | CLI parsing, interactive flow, orchestration             |
| `install/lib.sh`        | `link_file`, `copy_file`, backups, hyprctl helpers, sudo |
| `install/manifest.json` | Declarative groups: `mappings`, `globs`, flags           |
| `hypr/`, `waybar/`, …   | Source trees referenced by manifest `src` paths          |

`REPO_ROOT` in `lib.sh` is the parent of `install/` (git root).

</details>

<details>
<summary><strong>Manifest format</strong></summary>

Each group under `"groups"` in `manifest.json`:

| Field           | Meaning                                             |
| --------------- | --------------------------------------------------- |
| `label`         | Shown in `gum choose`                               |
| `default`       | Pre-selected in interactive multi-select            |
| `requires_sudo` | Needs write access under `/etc`, `/usr`, or `/boot` |
| `mappings`      | Exact `src` → `dst` pairs (repo-relative `src`)     |
| `globs`         | `src_glob` → files under `dst_dir`                  |

Destinations may use `$HOME`; `expand_vars()` replaces it with the installing user’s home.

Python helpers in `install.sh` (require `python3`):

- `py_groups` — `key`, `label`, `default`, `requires_sudo`
- `py_group_mappings` — `src` / `dst` per mapping
- `py_group_globs` — `src_glob` / `dst_dir` per glob

New components: add files under the repo and a group in the manifest — no installer code change unless you need new post-install logic.

</details>

<details>
<summary><strong><code>install_group</code> loop</strong></summary>

For each selected group key:

1. **Mappings** — For each `src` / `dst`: resolve under `REPO_ROOT`, expand `dst`, then `copy_file` or `link_file` per `should_copy_dst`.
2. **Globs** — Expand `src_glob` under `REPO_ROOT`; install under `dst_dir`. `extras_backgrounds` uses **basename only** (flat `~/Wallpapers`). Copy vs symlink: `extras_backgrounds` and system paths copy; else symlink.

</details>

<details>
<summary><strong><code>lib.sh</code> behaviors</strong></summary>

**`should_copy_dst`**

```text
/etc/*, /usr/*, /boot/*  →  copy
$HOME (except extras_backgrounds)  →  symlink
extras_backgrounds  →  copy
```

**`link_file` / `copy_file`**

1. `ensure_parent_dir` (`sudo` when destination is outside `$HOME`)
2. If destination exists: same symlink → no-op; file → backup `dst.old.<YYYYMMDD-HHMMSS>`; directory → warn and skip
3. `ln -nsf` or `cp -f`

**`sudo_warmup_if_needed`** — If any group has `requires_sudo`, runs `sudo -v` once; on failure, sudo groups are dropped from the selection.

**Hyprland monitors** — `hyprctl -j monitors all` + `jq`, or text parse fallback. Used when `hypr` is selected interactively unless monitor CLI flags are set.

Other helpers: `detect_timezone`, `maybe_warn_omarchy_version`, `require_gum`.

</details>

<details>
<summary><strong><code>install.sh</code> phases</strong></summary>

1. Parse flags (`--install`, `--skip`, monitors, timezone, services, deps, theme).
2. Interactive steps if no `--install`: theme confirm, group multi-select, monitors, timezone, yay prompts.
3. `install_deps_with_yay` when `--install-deps` or accepted interactively.
4. `maybe_install_theme` when `--install-theme` or confirmed.
5. `install_group` for each selected key.
6. `write_monitors_generated` / `write_windows_env` when applicable.
7. Post-install: `enable_systemd_user_units`, `post_install_fix_perms` (`bin`, `waybar`, `omarchy`), `post_install_boot_limine` for `boot`.

</details>

<details>
<summary><strong>Extending the installer</strong></summary>

1. Add config files under the repo tree.
2. Add a `groups` entry in `manifest.json` (`mappings` and/or `globs`).
3. New binaries → extend `install_deps_with_yay` in `install.sh`.
4. New executables → extend `post_install_fix_perms`.

Set `requires_sudo: true` for paths outside `$HOME`.

</details>

<details>
<summary><strong>Security notes</strong></summary>

- Groups `etc`, `boot`, `usr` write system paths with sudo — review those trees in the repo first.
- `omarchy/hooks/theme-set` can write Brave policy under `/etc/brave/...` when themes change.
- Secrets are not installed: `.gitignore` excludes `.env*`, keys, `rclone.conf`, etc. `windows/.env` is generated locally with timezone only.

</details>
