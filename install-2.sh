#!/bin/bash

# Yay
sudo -u $(whoami) git clone https://aur.archlinux.org/yay.git
sudo -u $(whoami) cd yay
sudo -u $(whoami) makepkg -si --noconfirm
sudo -u $(whoami) cd ..
sudo -u $(whoami) rm -rf yay

# Paquetes yay
sudo -u $(whoami) yay -S --noconfirm google-chrome visual-studio-code-bin minecraft-launcher opentabletdriver

# Opentablerdriver
systemctl --user enable --now opentabletdriver.service
echo "blacklist hid_uclogic" >> /etc/modprobe.d/blacklist.conf
rmmod hid_uclogic

# Eliminar
rm -rf ./install-2.sh
