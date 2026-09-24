# :house: My Omarchy Dotfiles

My Personal dotfiles and configuration scripts, based on [Catppuccin Mocha](https://github.com/sanidhyy/omarchy-catppuccin-mocha-theme "😺 Catppuccin Mocha Theme for Omarchy"), for [Omarchy Quattro](https://omarchy.org "Omarchy by DHH")

![Desktop Preview](/.github/images/img1.png "Desktop Preview")

## :sparkles: Tweaks

- :zap: Based on [Catppuccin Mocha](https://github.com/sanidhyy/omarchy-catppuccin-mocha-theme "😺 Catppuccin Mocha Theme for Omarchy").
- :desktop_computer: **Hyprland** window manager with OMARCHY-aligned tweaks for dual monitor setup.
- :lollipop: Catppuccin-styled **Waybar** with privacy dots, cava player, etc...
- :memo: **Kitty** terminal colors and settings configurations.
- :framed_picture: Custom **Elephant** Live Wallpaper picker menu.
- :rocket: **Starship** shell prompt styling.
- :art: **GTK** 3.0 and 4.0 styles for Catppuccin Mocha.
- :lock: **Limine** boot and **SDDM** login style configurations.
- :notes: **Cava** visualizer (Catppuccin Mocha theme) and **Cliamp** player config.
- :film_projector: **imv** image viewer and **mpv** player configs.
- :globe_with_meridians: **Brave** flags plus **Git** and **Lazygit** configs.
- :wrench: Configurations for **Btop**, **Fastfetch**, **SwayOSD**, etc...

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

**One or several folders**

```bash
stow hypr
stow hypr starship foot
./stow.sh hypr fastfetch
```

**All dotfiles**

```bash
./stow.sh
```

> > > :warning: Do not run `stow *` — that would also pick up `.github/`, `.gitignore`, `README.md` and other unwanted files.

**Update or remove**

```bash
stow -R hypr          # restow one package after a pull
./stow.sh -R          # restow everything
stow -D hypr          # unstow one package
./stow.sh -D          # unstow everything
./stow.sh -n          # dry-run (no links created)
./stow.sh -h          # script help
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

| Path                | Destination                                       |
| ------------------- | ------------------------------------------------- |
| `hypr/`             | `~/.config/hypr/`                                 |
| `waybar/`           | `~/.config/waybar/`                               |
| `kitty/`            | `~/.config/kitty/`                                |
| `starship/`         | `~/.config/starship.toml`                         |
| `gtk/`              | `~/.config/gtk-3.0/` and `~/.config/gtk-4.0/`     |
| `fastfetch/`        | `~/.config/fastfetch/`                            |
| `btop/`             | `~/.config/btop/`                                 |
| `swayosd/`          | `~/.config/swayosd/`                              |
| `cava/`             | `~/.config/cava/`                                 |
| `cliamp/`           | `~/.config/cliamp/`                               |
| `git/`              | `~/.config/git/`                                  |
| `lazygit/`          | `~/.config/lazygit/`                              |
| `imv/`              | `~/.config/imv/`                                  |
| `mpv/`              | `~/.config/mpv/`                                  |
| `brave/`            | `~/.config/brave-flags.conf`                      |
| `gamemode/`         | `~/.config/gamemode.ini`                          |
| `gpu_usage_waybar/` | `~/.config/gpu_usage_waybar.toml`                 |
| `bash/`             | `~/.bashrc`                                       |
| `local/`            | `~/.local/`                                       |
| `omarchy/`          | `~/.config/omarchy/`                              |
| `omarchy-custom/`   | `~/.config/omarchy-custom/`                       |
| `elephant/`         | `~/.config/elephant/`                             |
| `systemd/`          | `~/.config/systemd/`                              |
| `backgrounds/`      | `~/.config/omarchy/backgrounds/catppuccin-mocha/` |
| `system/`           | `/boot/`, `/usr/` (copy, not Stow)                |

## :pray: Credits

- [DHH](https://x.com/dhh "David Heinemeier Hansson") & [Omarchy Team](https://omarchy.org/teams "Omarchy Teams") for the excellent project.
- [Catppuccin](https://github.com/catppuccin "Catppuccin Mocha") community for the beautiful palette and ecosystem.

## :page_facing_up: License and Third-Party Notes

- All third-party assets (palettes, tools, wallpapers) retain their original licenses and copyrights.
- If you are the creator of any wallpaper in the `backgrounds/` folder and would like it removed or credited, please [Contact me](https://sanidhyy.name/#contact "Contact me at my email or through this form.").

## :warning: Disclaimer

These are my personal configs and might not work as expected on your machine. Feel free to contribute or open an issue if something seems wrong.
