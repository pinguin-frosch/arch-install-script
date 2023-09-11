#!/bin/bash

# Terminar el programa en caso de errores
set -e

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
export arch_root_password

echo -n "Nombre de usuario: "
read arch_username
export arch_username

echo -n "Contraseña de usuario: "
read arch_user_password
export arch_user_password

echo -n "Hostname: "
read arch_hostname
export arch_hostname

echo -n "Shell: "
read arch_shell
export arch_shell

echo -n "¿Instalar drivers nvidia? [s/n]: "
read arch_nvidia
export arch_nvidia

# Montar las particiones
mount $root_partition /mnt
mount --mkdir $efi_partition /mnt/boot
mount --mkdir $home_partition /mnt/home
swapon $swap_partition

# Obtener uuid de root y swap
export arch_root_uuid=$(lsblk -dno UUID $root_partition)
export arch_swap_uuid=$(lsblk -dno UUID $swap_partition)

# Copiar todo lo necesario al sistema
cp -r /root/arch-install-script /mnt/arch
chmod +x /mnt/arch/install-2.sh
env | grep "^arch" | sed "s|\(.*\)|export \1|" > /mnt/arch/envvars

# Mostrar las variables antes de continuar
cat /mnt/arch/envvars
echo -n "¿Está todo bien? Enter para continuar..."
read response

# Acelerar descargas de pacman y activar color
sed -i "s/^#\(Color\)/\1/" /etc/pacman.conf
sed -i "s/^#\(Parallel.*= \)\d/\18/" /etc/pacman.conf

# Asegurar que las firmas no estén vencidas
pacman -Sy --noconfirm archlinux-keyring

# Instalación básica
pacstrap /mnt base linux linux-firmware

# Fstab y chroot
genfstab -U /mnt >> /mnt/etc/fstab
arch-chroot /mnt /arch/install-2.sh

# Reiniciar
rm -rf /mnt/arch
reboot
