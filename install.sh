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
arch-chroot /mnt

#6. Software esencial
pacman -S --noconfirm grub efibootmgr os-prober vim plasma dolphin alacritty base-devel ark gnome-keyring gwenview ntfs-3g nvidia nvidia-prime obs-studio okular partitionmanager spectacle virtualbox virtualbox-guest-iso virtualbox-host-modules-arch vlc zsh zsh-completions networkmanager

#7. Software opcional
echo -n "¿Instalar software opcional? [s/n]: "
read b
if [[ $b == "s" ]]; then
    pacman -S --noconfirm kde-cli-tools ffmpegthumbs kdegraphics-thumbnailers p7zip unrar unarchiver lzop lrzip qt5-imageformats kimageformats ebook-tools kdegraphics-mobipocket libzip calligra
fi

#8. Configuración básica
ln -sf /usr/share/zoneinfo/America/Santiago /etc/localtime
hwclock --systohc
echo "es_CL.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
echo "LANG=es_CL.UTF-8" >> /etc/locale.conf
echo "KEYMAP=la-latin1" >> /etc/vconsole.conf
echo -n "Hostname: "
read hostname
echo "$hostname" >> /etc/hostname

#9. Configuración sudo
sed -i "s/^# %wheel ALL=(ALL) ALL.*/%wheel ALL=(ALL) ALL/" /etc/sudoers

#10. Instalación y configuración grub
grub-install --target=x86_64-efi --efi-directory=/efi --bootloader-id=GRUB
sed -i "s/^GRUB_DEFAULT=.*/GRUB_DEFAULT=saved/" /etc/default/grub
sed -i "s/^GRUB_TIMEOUT=.*/GRUB_TIMEOUT=2/" /etc/default/grub
sed -i "s/^GRUB_GFXMODE=.*/GRUB_GFXMODE=1920x1080x32,1280x720x32,auto/" /etc/default/grub
sed -i "s/^#GRUB_SAVEDEFAULT=.*/GRUB_SAVEDEFAULT=true/" /etc/default/grub
sed -i "s/^#GRUB_DISABLE_OS_PROBER=.*/GRUB_DISABLE_OS_PROBER=false/" /etc/default/grub
grub-mkconfig -o /boot/grub/grub.cfg

#11. Servicios
systemctl enable NetworkManager
systemctl enable sddm

#12. Contraseña root
echo "Constraseña root"
passwd

#13. Creación y configuración usuario
echo -n "Nombre de usuario: "
read username
useradd -m $username
echo "Constraseña de usuario"
passwd $username
usermod -aG wheel $username
usermod -s /usr/bin/zsh $username
echo -n "Comentario de usuario: "
read $comment
usermod -c "$comment" $username

#14. Reiniciar
exit
reboot
