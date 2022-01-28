#!/bin/bash

# Inicio
curl -LO raw.githubusercontent.com/pinguin-frosch/test/main/install_2.sh
chmod +x install_2.sh
loadkeys la-latin1
timedatectl set-ntp true >/dev/null

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

# Fstab y chroot
genfstab -U /mnt >> /mnt/etc/fstab
cp install_2.sh /mnt
arch-chroot /mnt ./install_2.sh

# Reiniciar
rm -rf /mnt/install_2.sh
reboot
