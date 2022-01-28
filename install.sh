#!/bin/bash
#1. Particionar
#2. Formatear
#3. Montar

# ln -sf /usr/share/zoneinfo/America/Santiago /etc/localtime
# hwclock --systohc
# echo "es_CL.UTF-8 UTF-8" >> /etc/locale.gen
# locale-gen >/dev/null
# echo "LANG=es_CL.UTF-8" >> /etc/locale.conf
# echo "KEYMAP=la-latin1" >> /etc/vconsole.conf
# echo -n "Hostname: "
# read hostname
# echo "$hostname" >> /etc/hostname
# echo -e "\nConstraseña root"
# passwd
# echo -ne "\nNombre de usuario: "
# read username
# useradd -m $username
# echo -e "\nConstraseña de usuario"
# passwd $username
# pacman -S --noconfirm grub efibootmgr os-prober vim
# grub-install --target=x86_64-efi --efi-directory=/efi --bootloader-id=GRUB
# sed -i "s/^GRUB_DEFAULT=.*/GRUB_DEFAULT=saved/" /etc/default/grub
# sed -i "s/^GRUB_TIMEOUT=.*/GRUB_TIMEOUT=2/" /etc/default/grub
# sed -i "s/^GRUB_GFXMODE=.*/GRUB_GFXMODE=1920x1080x32,1280x720x32,auto/" /etc/default/grub
# sed -i "s/^#GRUB_SAVEDEFAULT=.*/GRUB_SAVEDEFAULT=true/" /etc/default/grub
# sed -i "s/^#GRUB_DISABLE_OS_PROBER=.*/GRUB_DISABLE_OS_PROBER=false/" /etc/default/grub
# grub-mkconfig -o /boot/grub/grub.cfg
# pacman -S --noconfirm plasma dolphin alacritty base-devel ark gnome-keyring gwenview ntfs-3g nvidia nvidia-prime obs-studio okular partitionmanager spectacle virtualbox virtualbox-guest-iso virtualbox-host-modules-arch vlc zsh zsh-completions networkmanager
pacman -S kde-cli-tools ffmpegthumbs kdegraphics-thumbnailers p7zip unrar unarchiver lzop lrzip qt5-imageformats kimageformats ebook-tools kdegraphics-mobipocket libzip calligra
