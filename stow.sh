#!/usr/bin/env bash
set -euo pipefail

stow \
  backgrounds \
  bash \
  brave-origin \
  environment \
  fastfetch \
  foot \
  gamemode \
  git \
  gtk \
  hypr \
  imv \
  lazygit \
  local \
  mise \
  mpv \
  omarchy \
  starship \
  wireplumber

echo "Completed."
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
