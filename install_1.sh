#!/bin/bash

#0. Inicio
loadkeys la-latin1
timedatectl set-ntp true

#1. Particionar
lsblk
echo -n "Disco: "
read disk
cfdisk $disk

#2. Formatear
lsblk
echo -n "Partición root: "
read rootpartition
echo -n "Partición efi: "
read efipartition
echo -n "Partición swap: "
read swappartition
mkfs.ext4 $rootpartition
mkswap $swappartition
echo -n "¿Formatear efi? [s/n]: "
read a
if [[ $a == "s" ]]; then
    mkfs.fat -F 32 $efipartition
fi

#3. Montar
mount $rootpartition /mnt
swapon $swappartition
mkdir /mnt/efi && mount $efipartition /mnt/efi

#4. Instalación básica
pacstrap /mnt base linux linux-firmware

#5. fstab y chroot
genfstab -U /mnt >> /mnt/etc/fstab
arch-chroot /mnt ./install_2.sh

#15. Reiniciar
# reboot
