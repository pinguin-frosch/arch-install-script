#!/bin/bash

# Recuperar variables desde install-1.sh
source /arch/envvars

# Admnistración de paquetes
pacman -S --noconfirm --needed - < /arch/packages/system.txt
pacman -S --noconfirm --needed - < /arch/packages/desktop.txt
pacman -Rns --noconfirm discover
ln -s /usr/bin/ksshaskpass /usr/lib/ssh/ssh-askpass

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
envsubst < /arch/assets/arch.conf.tpl > /boot/loader/entries/arch.conf

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

# Copiar la distribución de teclado
mv /arch/assets/pro /usr/share/X11/xkb/symbols/

# Configurar teclado en sddm
echo "setxkbmap pro,latam" >> /usr/share/sddm/scripts/Xsetup

# Preparar paquetes de aur y yay para el usuario
git clone https://aur.archlinux.org/yay.git
chown -R $arch_username:$arch_username yay /arch/packages/aur.txt
mv yay /arch/packages/aur.txt /home/$arch_username

# Instalar yay en el sistema
sudo -u $arch_username bash << EOF
    cd /home/$arch_username/yay
    echo $arch_user_password | sudo -S pwd
    makepkg -si --noconfirm
EOF

# Borrar repositorio de yay
rm -r /home/$arch_username/yay

# Salir
exit
