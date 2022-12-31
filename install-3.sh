#!/bin/bash

# Yay
git clone https://aur.archlinux.org/yay.git
cd yay
echo $user_password | makepkg -si --noconfirm
cd ..
rm -rf yay

# Paquetes yay
echo $user_password | yay -S --noconfirm --needed - < yay.txt

# Eliminar
rm -rf ./install-3.sh ./yay.txt
