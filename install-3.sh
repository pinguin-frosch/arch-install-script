#!/bin/bash

# Yay
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si --noconfirm
cd ..
rm -rf yay

# Paquetes yay
yay -S --noconfirm --needed - < yay.txt

# Eliminar
rm -rf ./install-2.sh ./yay.txt
