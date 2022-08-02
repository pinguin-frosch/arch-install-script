#!/bin/bash

# Inicio
loadkeys la-latin1
timedatectl set-ntp true > /dev/null

# Describir particiones
lsblk -o NAME,SIZE,FSTYPE,MOUNTPOINTS,PATH,PARTLABEL
sleep 3

# Crear particiones
echo -n "¿Crear particiones? [s/n]: "
read response
if [[ $response == "s" ]]; then
    echo -n "Disco: "
    read disk
    cfdisk $disk

    # Mostrar las particiones nuevamente
    lsblk -o NAME,SIZE,FSTYPE,MOUNTPOINTS,PATH,PARTLABEL
    sleep 3
fi

# Registrar las particiones
echo -n "Partición efi:  "
read efipartition

echo -n "Partición root: "
read rootpartition

echo -n "Partición home: "
read homepartition

echo -n "Partición swap: "
read swappartition

# Formatear las particiones condicionalmente
echo -n "¿Formatear efi? [s/n]:  "
read efi
if [[ $efi == "s" ]]; then
    mkfs.fat -F 32 $efipartition
fi

echo -n "¿Formatear root? [s/n]: "
read root
if [[ $root == "s" ]]; then
    mkfs.ext4 $rootpartition
fi

echo -n "¿Formatear home? [s/n]: "
read home
if [[ $home == "s" ]]; then
    mkfs.ext4 $homepartition
fi

echo -n "¿Formatear swap? [s/n]: "
read swap
if [[ $swap == "s" ]]; then
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

echo -n "¿Usar teclado pro? [s/n]: "
read pro

echo -n "¿Usar zsh? [s/n]: "
read zsh

echo -n "¿Instalar software extra? [s/n]: "
read extra

echo -n "¿Instalar drivers nvidia? [s/n]: "
read nvidia

# Montar las particiones
mount $rootpartition /mnt
mount --mkdir $efipartition /mnt/boot
mount --mkdir $homepartition /mnt/home
swapon $swappartition

# Asegurar que las firmas no estén vencidas
pacman -Sy --noconfirm archlinux-keyring

# Instalación básica
pacstrap /mnt base linux linux-firmware

# Obtener parte 2
curl -LJO https://raw.githubusercontent.com/pinguin-frosch/arch-install-script/main/install-2.sh
curl -LJO https://raw.githubusercontent.com/pinguin-frosch/arch-install-script/main/programs/esencial.txt
curl -LJO https://raw.githubusercontent.com/pinguin-frosch/arch-install-script/main/programs/extra.txt
chmod +x install-2.sh
mv install-2.sh esencial.txt extra.ext /mnt

# Pasar datos a install-2.sh
echo "rootpassword=$rootpassword" >> envvars
echo "username=$username" >> envvars
echo "userpassword=$userpassword" >> envvars
echo "hostname=$hostname" >> envvars
echo "pro=$pro" >> envvars
echo "zsh=$zsh" >> envvars
echo "extra=$extra" >> envvars
echo "nvidia=$nvidia" >> envvars
mv envvars /mnt

# Fstab y chroot
genfstab -U /mnt >> /mnt/etc/fstab
arch-chroot /mnt ./install-2.sh

# Reiniciar
rm /mnt/install-2.sh /mnt/esencial.txt /mnt/extra.txt

reboot
