#!/bin/bash

#1. Software esencial
pacman -S --noconfirm grub efibootmgr os-prober vim stow plasma dolphin alacritty base-devel ark gnome-keyring gwenview ntfs-3g nvidia nvidia-prime obs-studio okular partitionmanager spectacle virtualbox virtualbox-guest-iso virtualbox-host-modules-arch vlc zsh zsh-completions networkmanager

#2. Software opcional
echo -n "¿Instalar software opcional? [s/n]: "
read b
if [[ $b == "s" ]]; then
    pacman -S --noconfirm kde-cli-tools ffmpegthumbs kdegraphics-thumbnailers p7zip unrar unarchiver lzop lrzip qt5-imageformats kimageformats ebook-tools kdegraphics-mobipocket libzip calligra
fi

#3. Configuración básica
ln -sf /usr/share/zoneinfo/America/Santiago /etc/localtime
hwclock --systohc
echo "es_CL.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
echo "LANG=es_CL.UTF-8" >> /etc/locale.conf
echo "KEYMAP=la-latin1" >> /etc/vconsole.conf
echo -n "Hostname: "
read hostname
echo "$hostname" >> /etc/hostname

#4. Configuración sudo
sed -i "s/^# %wheel ALL=(ALL) ALL.*/%wheel ALL=(ALL) ALL/" /etc/sudoers

#5. Instalación y configuración grub
grub-install --target=x86_64-efi --efi-directory=/efi --bootloader-id=GRUB
sed -i "s/^GRUB_DEFAULT=.*/GRUB_DEFAULT=saved/" /etc/default/grub
sed -i "s/^GRUB_TIMEOUT=.*/GRUB_TIMEOUT=2/" /etc/default/grub
sed -i "s/^GRUB_GFXMODE=.*/GRUB_GFXMODE=1920x1080x32,1280x720x32,auto/" /etc/default/grub
sed -i "s/^#GRUB_SAVEDEFAULT=.*/GRUB_SAVEDEFAULT=true/" /etc/default/grub
sed -i "s/^#GRUB_DISABLE_OS_PROBER=.*/GRUB_DISABLE_OS_PROBER=false/" /etc/default/grub
grub-mkconfig -o /boot/grub/grub.cfg

#6. Servicios
systemctl enable NetworkManager
systemctl enable sddm

#7. Contraseña root
echo "Constraseña root"
passwd

#8. Creación y configuración usuario
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

#9. Reiniciar
exit
reboot
