#!/bin/bash

# Yay
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si --noconfirm
cd ..
rm -rf yay

# Obtener paquetes yay
curl -LJO https://raw.githubusercontent.com/pinguin-frosch/arch-install-script/main/programs/yay.txt

# Paquetes yay
yay -S --noconfirm --needed - < yay.txt

# Eliminar
rm -rf ./install-3.sh ./yay.txt
