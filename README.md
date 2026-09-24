# :house: My Omarchy Dotfiles

My Personal dotfiles and configuration scripts, based on [Catppuccin Mocha](https://github.com/sanidhyy/omarchy-catppuccin-mocha-theme "😺 Catppuccin Mocha Theme for Omarchy"), for [Omarchy Quattro](https://omarchy.org "Omarchy by DHH")

![Desktop Preview](/.github/images/img1.png "Desktop Preview")

## :sparkles: Tweaks

- :zap: Based on [Catppuccin Mocha](https://github.com/sanidhyy/omarchy-catppuccin-mocha-theme "😺 Catppuccin Mocha Theme for Omarchy").
- :desktop_computer: **Hyprland** dual-monitor layout, custom binds, night light, and look-and-feel overrides.
- :lollipop: Omarchy **shell** bar with custom workspace, audio, and lock plugins.
- :computer: **Foot** terminal cursor and keybinding tweaks.
- :rocket: Catppuccin-styled **Starship** prompt and **Bash** aliases.
- :art: **GTK** 3.0 and 4.0 styles for Catppuccin Mocha.
- :framed_picture: Extra **backgrounds** for the Catppuccin Mocha wallpaper set.
- :lock: **Limine** boot and **SDDM** login style configurations.
- :film_projector: **imv** image viewer and **mpv** player configs.
- :globe_with_meridians: **Brave Origin** flags plus **Git** and **Lazygit** configs.
- :joystick: **Gamemode** and Steam Big Picture helpers, plus **WirePlumber** device rules.
- :wrench: **Fastfetch**, **mise**, and NVIDIA shader-cache environment settings.

## :camera_flash: Preview

![VS Code · LazyVim · Cliamp](/.github/images/img2.png "VS Code · LazyVim · Cliamp")

![LazyVim · Chromium · Walker](/.github/images/img3.png "LazyVim · Chromium · Walker")

![Hyprlock Preview](/.github/images/img4.png "Hyprlock Preview")

![Unlock Preview](/.github/images/img5.png "Unlock Preview")

## :package: Using Stow

You can use [GNU Stow](https://www.gnu.org/software/stow/) to easily manage your dotfiles.

```bash
# Arch Linux
sudo pacman -S stow

# Debian / Ubuntu
sudo apt install stow

# Fedora
sudo dnf install stow

git clone https://github.com/sanidhyy/dotfiles.git
cd dotfiles
```

Run Stow from the repo root.

**One or more files**

```bash
stow hypr
stow hypr starship foot
```

**All dotfiles**

```bash
./stow.sh
```

> > > :warning: Do not run `stow *` — that would also pick up `.github/`, `.gitignore`, `README.md` and other unwanted files.

**Update or remove**

```bash
stow -R hypr          # restow one package after a pull
stow -D hypr          # unstow one package
stow -n hypr          # dry-run (no links created)
```

**Manually copy System files.** Copy them (do not symlink).

```bash
# backup old files
sudo cp /boot/limine.conf /boot/limine.conf.bak
sudo cp /usr/share/sddm/themes/omarchy/Main.qml /usr/share/sddm/themes/omarchy/Main.qml.bak

# copy new files
sudo cp system/boot/limine.conf /boot/limine.conf
sudo cp system/usr/share/sddm/themes/omarchy/Main.qml /usr/share/sddm/themes/omarchy/Main.qml
```

## :file_folder: Layout

| Path            | Destination                                       |
| --------------- | ------------------------------------------------- |
| `backgrounds/`  | `~/.config/omarchy/backgrounds/catppuccin-mocha/` |
| `bash/`         | `~/.bashrc`                                       |
| `brave-origin/` | `~/.config/brave-origin-flags.conf`               |
| `environment/`  | `~/.config/environment.d/`                        |
| `fastfetch/`    | `~/.config/fastfetch/`                            |
| `foot/`         | `~/.config/foot/`                                 |
| `gamemode/`     | `~/.config/gamemode.ini`                          |
| `git/`          | `~/.config/git/`                                  |
| `gtk/`          | `~/.config/gtk-3.0/` and `~/.config/gtk-4.0/`     |
| `hypr/`         | `~/.config/hypr/`                                 |
| `imv/`          | `~/.config/imv/`                                  |
| `lazygit/`      | `~/.config/lazygit/`                              |
| `local/`        | `~/.local/`                                       |
| `mise/`         | `~/.config/mise/`                                 |
| `mpv/`          | `~/.config/mpv/`                                  |
| `omarchy/`      | `~/.config/omarchy/`                              |
| `starship/`     | `~/.config/starship.toml`                         |
| `wireplumber/`  | `~/.config/wireplumber/`                          |
| `system/`       | `/boot/`, `/usr/` (copy, not Stow)                |

## :pray: Credits

- [DHH](https://x.com/dhh "David Heinemeier Hansson") & [Omarchy Team](https://omarchy.org/teams "Omarchy Teams") for the excellent project.
- [Catppuccin](https://github.com/catppuccin "Catppuccin Mocha") community for the beautiful palette and ecosystem.

## :page_facing_up: License and Third-Party Notes

- All third-party assets (palettes, tools, wallpapers) retain their original licenses and copyrights.
- If you are the creator of any wallpaper in the `backgrounds/` folder and would like it removed or credited, please [Contact me](https://sanidhyy.name/#contact "Contact me at my email or through this form.").

## :warning: Disclaimer

These are my personal configs and might not work as expected on your machine. Feel free to contribute or open an issue if something seems wrong.
