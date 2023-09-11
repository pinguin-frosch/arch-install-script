#!/bin/bash

# Terminar el programa en caso de errores
set -e

# Recuperar variables desde install-1.sh
source /arch/envvars

# Acelerar descargas de pacman y activar color
sed -i "s/^#\(Color\)/\1/" /etc/pacman.conf
sed -i "s/^#\(Parallel.*= \).*/\18/" /etc/pacman.conf

# Crear lista de paquetes
cat /arch/packages/system.txt /arch/packages/desktop.txt >> /arch/packages/all.txt
if [[ $arch_nvidia == "s" ]]; then
    cat /arch/packages/nvidia.txt >> /arch/packages/all.txt
fi

# Instalar paquetes
pacman -S --noconfirm --needed - < /arch/packages/all.txt
pacman -Rns --noconfirm discover
ln -s /usr/bin/ksshaskpass /usr/lib/ssh/ssh-askpass

# Contraseña root
echo -e "$arch_root_password\n$arch_root_password" | passwd

# Creación y configuración usuario
useradd -m $arch_username
echo -e "$arch_user_password\n$arch_user_password" | passwd $arch_username
usermod -aG wheel,docker,vboxusers $arch_username
usermod -s /usr/bin/fish $arch_username

# Configuración básica
echo "$arch_hostname" >> /etc/hostname
ln -sf /usr/share/zoneinfo/America/Santiago /etc/localtime
hwclock --systohc
sed -i "s/^#\(es_CL.*UTF-8\)/\1/" /etc/locale.gen
sed -i "s/^#\(en_US.*UTF-8\)/\1/" /etc/locale.gen
sed -i "s/^#\(de_DE.*UTF-8\)/\1/" /etc/locale.gen
locale-gen
echo "LANG=es_CL.UTF-8" >> /etc/locale.conf
echo "KEYMAP=la-latin1" >> /etc/vconsole.conf

# Configuración sudo
sed -i "s/^# \(%wheel ALL=(ALL:ALL) ALL\)/\1/" /etc/sudoers

# Instalación y configuración systemd-boot
bootctl install
echo -e "default @saved\ntimeout 2\nconsole-mode max" > /boot/loader/loader.conf
envsubst < /arch/assets/arch.conf.tpl > /boot/loader/entries/arch.conf

# Registrar hook para hibernación
sed -i "s/^\(HOOKS=.*filesystems\)/\1 resume/" /etc/mkinitcpio.conf
mkinitcpio -p linux

# Servicios
systemctl enable NetworkManager
systemctl enable sddm
systemctl enable bluetooth
systemctl enable cups
systemctl enable docker

# Configurar distribución de teclado
mv /arch/assets/pro /usr/share/X11/xkb/symbols/
mv /arch/assets/00-keyboard.conf /etc/X11/xorg.conf.d/

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
