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
read efi_partition

echo -n "Partición root: "
read root_partition

echo -n "Partición home: "
read home_partition

echo -n "Partición swap: "
read swap_partition

# Formatear las particiones condicionalmente
echo -n "¿Formatear efi? [s/n]:  "
read efi
if [[ $efi == "s" ]]; then
    mkfs.fat -F 32 $efi_partition
fi

echo -n "¿Formatear root? [s/n]: "
read root
if [[ $root == "s" ]]; then
    mkfs.ext4 $root_partition
fi

echo -n "¿Formatear home? [s/n]: "
read home
if [[ $home == "s" ]]; then
    mkfs.ext4 $home_partition
fi

echo -n "¿Formatear swap? [s/n]: "
read swap
if [[ $swap == "s" ]]; then
    mkswap $swap_partition
fi

# Inputs
echo -n "Contraseña root: "
read arch_root_password

echo -n "Nombre de usuario: "
read arch_username

echo -n "Contraseña de usuario: "
read arch_user_password

echo -n "Hostname: "
read arch_hostname

echo -n "Directorio de trabajo: "
read arch_workdir

echo -n "Shell: "
read arch_shell

echo -n "¿Instalar drivers nvidia? [s/n]: "
read arch_nvidia

echo -n "¿Instalar dotfiles? [s/n]: "
read arch_dotfiles

# Montar las particiones
mount $root_partition /mnt
mount --mkdir $efi_partition /mnt/boot
mount --mkdir $home_partition /mnt/home
swapon $swap_partition

# Obtener uuid de root y swap
export arch_root_uuid=$(lsblk -dno UUID $root_partition)
export arch_swap_uuid=$(lsblk -dno UUID $swap_partition)

# Asegurar que las firmas no estén vencidas
pacman -Sy --noconfirm archlinux-keyring

# Instalación básica
pacstrap /mnt base linux linux-firmware

# Obtener parte 2
curl -LJO https://raw.githubusercontent.com/pinguin-frosch/arch-install-script/$rama/install-2.sh
curl -LJO https://raw.githubusercontent.com/pinguin-frosch/arch-install-script/$rama/programs/pacman.txt
chmod +x install-2.sh
mv install-2.sh pacman.txt /mnt

# Pasar datos a install-2.sh
env | grep "^arch" | sed "s|\(.*\)|export \1|" > /mnt/envvars

# Fstab y chroot
genfstab -U /mnt >> /mnt/etc/fstab
arch-chroot /mnt ./install-2.sh

# Reiniciar
rm /mnt/install-2.sh /mnt/pacman.txt
reboot
