#!/bin/bash

# Yay
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si --noconfirm
cd ..
rm -rf yay

# Paquetes yay
yay -S --noconfirm google-chrome visual-studio-code-bin minecraft-launcher opentabletdriver

# Eliminar
rm -rf ./install-2.sh
