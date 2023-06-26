#!/bin/bash

# Recuperar datos install-1.sh
source envvars

# Software a instalar
pacman -S --noconfirm --needed - < pacman.txt
ln -s /usr/bin/ksshaskpass /usr/lib/ssh/ssh-askpass

# Software a borrar
pacman -Rns --noconfirm discover

# Nvidia
if [[ $arch_nvidia == "s" ]]; then
    pacman -S --noconfirm --needed nvidia nvidia-utils nvidia-settings nvidia-prime
fi

# Contraseña root
echo -e "$arch_root_password\n$arch_root_password" | passwd

# Creación y configuración usuario
useradd -m $arch_username
echo -e "$arch_user_password\n$arch_user_password" | passwd $arch_username
usermod -aG wheel,docker,vboxusers $arch_username
usermod -s /usr/bin/$arch_shell $arch_username

# Configuración básica
echo "$arch_hostname" >> /etc/hostname
ln -sf /usr/share/zoneinfo/America/Santiago /etc/localtime
hwclock --systohc
sed -i "s/^#es_CL.UTF-8 UTF-8/es_CL.UTF-8 UTF-8/" /etc/locale.gen
sed -i "s/^#Color/Color/" /etc/pacman.conf
sed -i "s/^#Parallel.*/ParallelDownloads = 5/" /etc/pacman.conf
locale-gen
echo "LANG=es_CL.UTF-8" >> /etc/locale.conf
echo "KEYMAP=la-latin1" >> /etc/vconsole.conf

# Configuración sudo
sed -i "s/^# %wheel ALL=(ALL:ALL) ALL.*/%wheel ALL=(ALL:ALL) ALL/" /etc/sudoers
echo "Defaults timestamp_timeout=30" >> /etc/sudoers

# Instalación y configuración systemd-boot
bootctl install
echo -e "default @saved\ntimeout 2\nconsole-mode max" > /boot/loader/loader.conf
echo -e "title Arch Linux\nlinux /vmlinuz-linux\ninitrd /initramfs-linux.img\noptions root=UUID=$root_uuid rw quiet loglevel=3 resume=UUID=$swap_uuid" > /boot/loader/entries/arch.conf

# Registrar hook para hibernación
sed -i "s|keyboard|resume keyboard|" /etc/mkinitcpio.conf
mkinitcpio -p linux

# Servicios
systemctl enable NetworkManager
systemctl enable sddm
systemctl enable bluetooth
systemctl enable cups
systemctl enable power-profiles-daemon
systemctl enable docker

# Descargar y registrar pro
curl -LJO https://raw.githubusercontent.com/pinguin-frosch/arch-install-script/$rama/keymap/pro
mv pro /usr/share/X11/xkb/symbols/.

# Configurar teclado en sddm
echo "setxkbmap pro,latam" >> /usr/share/sddm/scripts/Xsetup

# Descargar yay y los paquetes de AUR
curl -LJO https://raw.githubusercontent.com/pinguin-frosch/arch-install-script/$rama/programs/yay.txt
git clone https://aur.archlinux.org/yay.git

# Mover archivos a /home/$username
chown -R $arch_username:$arch_username yay yay.txt
mv yay.txt yay /home/$arch_username

sudo -u $arch_username bash << EOF
    cd /home/$arch_username
    cd yay

    # Solo sudo soporta leer la contraseña de stdin
    echo $arch_user_password | sudo -S pwd

    makepkg -si --noconfirm
    cd ..
    yay -S --noconfirm --needed - < yay.txt
    rm -rf yay yay.txt
EOF

# Descargar y configurar dotfiles
if [[ $arch_dotfiles == "s" ]]; then
    git clone https://github.com/pinguin-frosch/dotfiles.git
    chown -R $arch_username:$arch_username dotfiles
    mkdir -p /home/$arch_username/$arch_workdir
    mv dotfiles /home/$arch_username/$arch_workdir
    cd /home/$arch_username/$workdir/dotfiles
    bash setup.sh stow
    sudo -u $arch_username bash << EOF
        git remote set-url origin git@github.com:pinguin-frosch/dotfiles.git
EOF
fi

# Eliminar envvars
rm /envvars

# Salir
exit
