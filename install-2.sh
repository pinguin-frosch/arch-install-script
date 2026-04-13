#!/bin/bash

# Exit in case of any error
set -e

# Source variables from install-1.sh
source /artix/envvars

# Speed up pacman downloads and enable color mode
sed -i "s/^#\(Color\)/\1/" /etc/pacman.conf
sed -i "s/^\(Parallel.*= \).*/\18/" /etc/pacman.conf

# Create package list to install
cat /artix/packages/system.txt /artix/packages/plasma.txt >> /artix/packages/all.txt
if [[ $artix_install_development == "y" ]]; then
    cat /artix/packages/development.txt >> /artix/packages/all.txt
fi
if [[ $artix_install_desktop_apps == "y" ]]; then
    cat /artix/packages/desktop-apps.txt >> /artix/packages/all.txt
fi
if [[ $artix_install_nvidia == "y" ]]; then
    cat /artix/packages/nvidia.txt >> /artix/packages/all.txt
fi

# Install packages and restart if there's a network fail or bad internet
until pacman -S --noconfirm --needed - < /artix/packages/all.txt; do
    echo "--> Network dropped or pacman failed. Retrying in 3 seconds..."
    sleep 3
done

# Setup root password
echo -e "$artix_root_password\n$artix_root_password" | passwd

# Create and configure user
useradd -m $artix_username
echo -e "$artix_user_password\n$artix_user_password" | passwd $artix_username
usermod -s /usr/bin/fish $artix_username
usermod -aG wheel $artix_username
if [[ $artix_install_development == "y" ]]; then
    usermod -aG docker,vboxusers $artix_username
fi

# Basic system setup
echo "$artix_hostname" >> /etc/hostname
ln -sf /usr/share/zoneinfo/America/Santiago /etc/localtime
hwclock --systohc
sed -i "s/^#\(es_CL.*UTF-8\)/\1/" /etc/locale.gen
sed -i "s/^#\(en_US.*UTF-8\)/\1/" /etc/locale.gen
sed -i "s/^#\(de_DE.*UTF-8\)/\1/" /etc/locale.gen
locale-gen
echo "KEYMAP=la-latin1" >> /etc/vconsole.conf
echo "LANG=en_US.UTF-8" >> /etc/locale.conf

# Enable wheel group for sudo access
sed -i "s/^# \(%wheel ALL=(ALL:ALL) ALL\)/\1/" /etc/sudoers

# Balance faillock values
sed -E -i \
    -e "s|^#?\s*(deny).*|\1 = 10|" \
    -e "s|^#?\s*(fail_interval).*|\1 = 300|" \
    -e "s|^#?\s*(unlock_time).*|\1 = 30|" \
    /etc/security/faillock.conf

# Install and setup grub bootloader
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=grub
sed -i "s/^#\(GRUB_DISABLE_OS_PROBER=\).*/\1false/" /etc/default/grub

# Remember last used os
sed -E -i \
    -e "s|^#?\s*(GRUB_SAVEDEFAULT=).*|\1true|" \
    -e "s|^#?\s*(GRUB_DEFAULT=).*|\1saved|" \
    /etc/default/grub

# Reduce grub timeout
sed -E -i "s|(GRUB_TIMEOUT)=.*|\1=2|" /etc/default/grub

# Enable hibernation
sed -i "s/\(GRUB_CMDLINE_LINUX_DEFAULT=\"[^\"]*\)/\1 resume=UUID=$artix_swap_uuid/" /etc/default/grub
sed -i "s/^\(HOOKS=.*filesystems\)/\1 resume/" /etc/mkinitcpio.conf
mkinitcpio -p linux

# Save grub config to the system
grub-mkconfig -o /boot/grub/grub.cfg

# Enable services
mkdir -p /etc/dinit.d/boot.d/
ln -sf ../ntpd /etc/dinit.d/boot.d/
ln -sf ../NetworkManager /etc/dinit.d/boot.d/
ln -sf ../bluetoothd /etc/dinit.d/boot.d/
ln -sf ../cupsd /etc/dinit.d/boot.d/
ln -sf ../sddm /etc/dinit.d/boot.d/
ln -sf ../sshd /etc/dinit.d/boot.d/
ln -sf ../ufw /etc/dinit.d/boot.d/
ln -sf /usr/lib/dinit.d/dinit-user-spawn /etc/dinit.d/boot.d/dinit-user-spawn
if [[ $artix_install_development == "y" ]]; then
    ln -sf ../dockerd /etc/dinit.d/boot.d/
fi

# Copy the tuned services, but don't enable them as they aren't installed just yet
cp /artix/assets/tuned /artix/assets/tuned-ppd /etc/dinit.d/
chmod 644 /etc/dinit.d/tuned /etc/dinit.d/tuned-ppd

# Add breeze theme to sddm automatically
mkdir -p /etc/sddm.conf.d/
cp /artix/assets/kde_settings.conf /etc/sddm.conf.d/

# Configure my custom keyboard layout
mv /artix/assets/pro /usr/share/X11/xkb/symbols/
mv /artix/assets/00-keyboard.conf /etc/X11/xorg.conf.d/
sed -i "/<\/layoutList>/i\\
    <layout>\\
      <configItem>\\
        <name>pro</name>\\
        <shortDescription>pro</shortDescription>\\
        <description>Programming</description>\\
        <languageList>\\
          <iso639Id>eng</iso639Id>\\
          <iso639Id>deu</iso639Id>\\
          <iso639Id>spa</iso639Id>\\
        </languageList>\\
      </configItem>\\
      <variantList/>\\
    </layout>" /usr/share/X11/xkb/rules/evdev.xml

# Install pragmasevka font
mkdir -p /tmp/ttf/
curl -sL https://github.com/shytikov/pragmasevka/releases/latest/download/Pragmasevka_NF.zip -o /tmp/pragmasevka.zip
unzip /tmp/pragmasevka.zip -d /tmp/ttf/
mkdir -p /usr/share/fonts/TTF/
cp /tmp/ttf/* /usr/share/fonts/TTF/
fc-cache -fv
chmod 644 /usr/share/fonts/TTF/*.ttf
rm -rf /tmp/ttf/

# Create the user directory for scripts
mkdir -p /home/$artix_username/.local/bin

# Copy swirl script/binary into the system
mv /artix/assets/swirl /home/$artix_username/.local/bin/

# Copy tmux-session-switch script to the system
if [[ $artix_install_development == "y" ]]; then
    mv /artix/assets/tmux-session-switch /home/$artix_username/.local/bin/
fi

# Copy prime-run script if necessary
if [[ $artix_install_nvidia == "y" ]]; then
    mv /artix/assets/prime-run /home/$artix_username/.local/bin/
fi

# Make all scripts executable
chmod +x /home/$artix_username/.local/bin/*

# Update ownership of the scripts so the user can run them
chown -R $artix_username:$artix_username /home/$artix_username/.local/

# Install tpm if necessary
if [[ $artix_install_development == "y" ]]; then
    mkdir -p /home/$artix_username/.config/tmux/plugins/
    git clone https://github.com/tmux-plugins/tpm /home/$artix_username/.config/tmux/plugins/tpm
    chown -R $artix_username:$artix_username /home/$artix_username/.config/
fi

# Clone yay
git clone https://aur.archlinux.org/yay.git
mkdir -p /home/$artix_username/Programming/aur/

# Move yay and aur.txt to the user folder
mv yay /artix/packages/aur.txt /home/$artix_username/Programming/aur/

# Change owner of the newly creted folder to avoid problems
chown -R $artix_username:$artix_username /home/$artix_username/Programming

# Temporarily give root access to the user without a password
echo "$artix_username ALL=(ALL:ALL) NOPASSWD: ALL" > /etc/sudoers.d/99-temp-aur-installer

# Install yay
sudo -u $artix_username bash << EOF
    cd /home/$artix_username/Programming/aur/yay/
    makepkg -si --noconfirm
EOF

# Remove temporarily given root acccess to the user
rm /etc/sudoers.d/99-temp-aur-installer

# Copy install-3.sh to the user $HOME folder
mv /artix/install-3.sh /home/$artix_username
chmod +x /home/$artix_username/install-3.sh
chown $artix_username:$artix_username /home/$artix_username/install-3.sh

exit
