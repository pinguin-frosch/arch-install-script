#!/bin/bash

# Yay
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si --noconfirm
cd ..
rm -rf yay

# Paquetes yay
yay -S --noconfirm --needed - < yay.txt

# Configuración ksshaskpass
ln -s /usr/bin/ksshaskpass /usr/lib/ssh/ssh-askpass

# Eliminar
rm -rf ./install-2.sh ./yay.txt
