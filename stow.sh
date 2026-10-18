#!/usr/bin/env bash
set -euo pipefail

stow \
  bash \
  brave-origin \
  environment \
  fastfetch \
  foot \
  gamemode \
  gtk \
  hypr \
  imv \
  lazygit \
  local \
  mise \
  mpv \
  nvim \
  omarchy \
  starship \
  systemd \
  wireplumber

echo "Completed."
echo
echo "Enable systemd user service. Run:"
echo
echo "  systemctl --user daemon-reload"
echo "  systemctl --user enable --now omarchy-theme-bg-random.service"
echo
echo "Install the Hardware Monitor plugin. Run:"
echo
echo "  # add plugin"
echo "  omarchy plugin add https://github.com/meviusisback/omarchy-hw-monitor.git --enable"
echo "  # move plugin to center before omarchy clock"
echo "  omarchy bar move meviusisback.hw-monitor --section center --before omarchy.clock"
echo
echo "System files are not stowed. Copy them manually (do not symlink):"
echo
echo "  # backup old files"
echo "  sudo cp /boot/limine.conf /boot/limine.conf.bak"
echo "  sudo cp /usr/share/sddm/themes/omarchy/Main.qml /usr/share/sddm/themes/omarchy/Main.qml.bak"
echo
echo "  # copy new files"
echo "  sudo cp system/boot/limine.conf /boot/limine.conf"
echo "  sudo cp system/usr/share/sddm/themes/omarchy/Main.qml /usr/share/sddm/themes/omarchy/Main.qml"
echo
echo "  # regenerate limine entries"
echo "  sudo limine-update"
echo "  sudo limine-snapper-sync"
echo
echo
echo "Read more at: https://github.com/sanidhyy/dotfiles#package-using-stow"
