#!/bin/bash

# Recuperar datos install-1.sh
source envvars

# Software esencial
pacman -S --noconfirm --needed - < pacman.txt

# Contraseña root
echo -e "$rootpassword\n$rootpassword" | passwd
 
# Creación y configuración usuario
useradd -m $username
echo -e "$userpassword\n$userpassword" | passwd $username
usermod -aG wheel $username
usermod -s /usr/bin/zsh $username

# Configuración básica
echo "$hostname" >> /etc/hostname
ln -sf /usr/share/zoneinfo/America/Santiago /etc/localtime
hwclock --systohc
# echo "es_CL.UTF-8 UTF-8" >> /etc/locale.gen
sed -i "s/^#es_CL.UTF-8 UTF-8/es_CL.UTF-8 UTF-8/" /etc/locale.gen
locale-gen
echo "LANG=es_CL.UTF-8" >> /etc/locale.conf
echo "KEYMAP=la-latin1" >> /etc/vconsole.conf

# Configuración sudo
sed -i "s/^# %wheel ALL=(ALL) ALL.*/%wheel ALL=(ALL) ALL/" /etc/sudoers

# Instalación y configuración grub
grub-install --target=x86_64-efi --efi-directory=/efi --bootloader-id=GRUB
sed -i "s/^GRUB_DEFAULT=.*/GRUB_DEFAULT=saved/" /etc/default/grub
sed -i "s/^GRUB_TIMEOUT=.*/GRUB_TIMEOUT=2/" /etc/default/grub
sed -i "s/^GRUB_GFXMODE=.*/GRUB_GFXMODE=1920x1080x32,1280x720x32,auto/" /etc/default/grub
sed -i "s/^#GRUB_SAVEDEFAULT=.*/GRUB_SAVEDEFAULT=true/" /etc/default/grub
sed -i "s/^#GRUB_DISABLE_OS_PROBER=.*/GRUB_DISABLE_OS_PROBER=false/" /etc/default/grub
grub-mkconfig -o /boot/grub/grub.cfg

# Servicios
systemctl enable NetworkManager
systemctl enable sddm

# Distrubución de teclado
curl -LJO https://raw.githubusercontent.com/pinguin-frosch/arch-install-script/main/keymap/pro
cp -rf pro /usr/share/X11/xkb/symbols/.
rm -rf pro
sed -i "s,<name>custom</name>,<name>pro</name>," /usr/share/X11/xkb/rules/evdev.xml
sed -i "s,<shortDescription>custom</shortDescription>,<shortDescription>pro</shortDescription>," /usr/share/X11/xkb/rules/evdev.xml
sed -i "s,<description>A user-defined custom Layout</description>,<description>programming</description>," /usr/share/X11/xkb/rules/evdev.xml
sed -i "s,<description>programming</description>,<description>programming</description>\n        <languageList>\n          <iso639Id>spa</iso639Id>\n        </languageList>," /usr/share/X11/xkb/rules/evdev.xml
echo "setxkbmap pro,ru,gr" >> /usr/share/sddm/scripts/Xsetup

# Fuente
curl -LJO https://github.com/microsoft/cascadia-code/releases/download/v2111.01/CascadiaCode-2111.01.zip
unzip CascadiaCode-2111.01.zip
cp -rf ttf/* /usr/share/fonts
rm -rf woff2/ otf/ ttf/ CascadiaCode-2111.01.zip

# Continuación
curl -LJO https://raw.githubusercontent.com/pinguin-frosch/arch-install-script/main/install-3.sh
curl -LJO https://raw.githubusercontent.com/pinguin-frosch/arch-install-script/main/programs/yay.txt
chown $username:$username install-3.sh
chown $username:$username yay.txt
chmod u+x install-3.sh
mv install-3.sh yay.txt /home/$username/.

# Salir
exit
