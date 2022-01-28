#!/bin/bash

# Inicio
chmod +x install*.sh
cp install_2.sh /mnt
loadkeys la-latin1
timedatectl set-ntp true

# Particionar
lsblk
echo -n "Disco: "
read disk
cfdisk $disk

# Formatear
lsblk
echo -n "Partición efi:  "
read efipartition
echo -n "¿Formatear efi? [s/n]:  "
read a
if [[ $a == "s" ]]; then
    mkfs.fat -F 32 $efipartition
fi

echo -n "Partición root: "
read rootpartition
echo -n "¿Formatear root? [s/n]: "
read b
if [[ $b == "s" ]]; then
    mkfs.ext4 $rootpartition
fi

echo -n "Partición swap: "
read swappartition
echo -n "¿Formatear swap? [s/n]: "
read c
if [[ $c == "s" ]]; then
    mkswap $swappartition
fi

# Montar
mount $rootpartition /mnt
mkdir /mnt/efi && mount $efipartition /mnt/efi
swapon $swappartition

# Instalación básica
pacstrap /mnt base linux linux-firmware

# fstab y chroot
genfstab -U /mnt >> /mnt/etc/fstab
arch-chroot /mnt

# Reiniciar
# reboot
