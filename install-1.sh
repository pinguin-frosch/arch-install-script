#!/bin/bash

# Inicio
loadkeys la-latin1
timedatectl set-ntp true >/dev/null

# Particionar
lsblk
sleep 1
echo -n "Disco: "
read disk
cfdisk $disk

# Formatear
lsblk
sleep 1

echo -n "Partición efi:  "
read efipartition
echo -n "Partición root: "
read rootpartition
echo -n "Partición swap: "
read swappartition
echo -n "¿Formatear efi? [s/n]:  "
read a

if [[ $a == "s" ]]; then
    mkfs.fat -F 32 $efipartition
fi
echo -n "¿Formatear root? [s/n]: "
read b
if [[ $b == "s" ]]; then
    mkfs.ext4 $rootpartition
fi
echo -n "¿Formatear swap? [s/n]: "
read c
if [[ $c == "s" ]]; then
    mkswap $swappartition
fi

# Inputs
echo -n "Contraseña root: "
read rootpassword

echo -n "Nombre de usuario: "
read username

echo -n "Contraseña de usuario: "
read userpassword

echo -n "Hostname: "
read hostname

# Montar
mount $rootpartition /mnt
mkdir /mnt/efi && mount $efipartition /mnt/efi
swapon $swappartition

# Instalación básica
pacstrap /mnt base linux linux-firmware

# Obtener parte 2
curl -LJO https://raw.githubusercontent.com/pinguin-frosch/arch-install-script/main/install-2.sh
curl -LJO https://raw.githubusercontent.com/pinguin-frosch/arch-install-script/main/programs/pacman.txt
chmod +x install-2.sh
mv install-2.sh /mnt
mv pacman.txt /mnt

# Pasar datos a install-2.sh
echo "rootpassword=$rootpassword" >> envvars
echo "username=$username" >> envvars
echo "userpassword=$userpassword" >> envvars
echo "hostname=$hostname" >> envvars
mv envvars /mnt

# Fstab y chroot
genfstab -U /mnt >> /mnt/etc/fstab
arch-chroot /mnt ./install-2.sh

# Reiniciar
rm /mnt/install-2.sh /mnt/pacman.txt
reboot
