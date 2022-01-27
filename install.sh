#!/bin/bash
#1. Particionar
#2. Formatear
#3. Montar

ln -sf /usr/share/zoneinfo/America/Santiago /etc/localtime
hwclock --systohc
echo "es_CL.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
echo "LANG=es_CL.UTF-8" >> /etc/locale.conf
echo "KEYMAP=la-latin1" >> /etc/vconsole.conf
echo -n "Hostname: "
read hostname
echo "$hostname" >> /etc/hostname
passwd
