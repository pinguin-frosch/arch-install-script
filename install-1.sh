#!/bin/bash

# Exit in case of any error
set -e

# Describe partitions
lsblk -o NAME,LABEL,PATH,SIZE,FSTYPE,MOUNTPOINTS

# Create partitions
echo -n "Partition disk? [y/N]: "
read response
if [[ $response == "y" ]]; then
    echo -n "Disk: "
    read disk
    cfdisk $disk

    echo "Syncing partition table..."
    partx -u $disk 2>/dev/null || true
    udevadm settle

    # Show the partitions again
    lsblk -o NAME,LABEL,PATH,SIZE,FSTYPE,MOUNTPOINTS
fi

# Register partitions
echo -n "ESP Partition:  "
read esp_partition

echo -n "ROOT Partition: "
read root_partition

echo -n "HOME Partition: "
read home_partition

echo -n "SWAP Partition: "
read swap_partition

# Format partitions conditionally
echo -n "Format ESP? [y/N]:  "
read format_esp
if [[ $format_esp == "y" ]]; then
    mkfs.fat -F 32 $esp_partition
    fatlabel $esp_partition ESP
fi

echo -n "Format ROOT? [y/N]: "
read format_root
if [[ $format_root == "y" ]]; then
    mkfs.ext4 -L ROOT $root_partition
fi

echo -n "Format HOME? [y/N]: "
read format_home
if [[ $format_home == "y" ]]; then
    mkfs.ext4 -L HOME $home_partition
fi

echo -n "Format SWAP [y/N]: "
read format_swap
if [[ $format_swap == "y" ]]; then
    mkswap -L SWAP $swap_partition
fi

# Inputs
echo -n "Root password: "
read artix_root_password
export artix_root_password

echo -n "Username: "
read artix_username
export artix_username

echo -n "User password: "
read artix_user_password
export artix_user_password

echo -n "Hostname: "
read artix_hostname
export artix_hostname

echo -n "Install development packages? [y/N]: "
read artix_install_development
export artix_install_development

echo -n "Install desktop apps packages? [y/N]: "
read artix_install_desktop_apps
export artix_install_desktop_apps

echo -n "Install nvidia packages? [y/N]: "
read artix_install_nvidia
export artix_install_nvidia

# Mount partitions
mount $root_partition /mnt
mount --mkdir $esp_partition /mnt/boot/efi
mount --mkdir $home_partition /mnt/home
swapon $swap_partition

# Copy everything to the chroot
mkdir -p /mnt/artix
cp -r /root/arch-install-script/* /mnt/artix # TODO: rename to artix after renaming repo
chmod +x /mnt/artix/install-2.sh
env | grep "^artix" | sed 's|\([^=]*=\)\(.*\)|export \1"\2"|' > /mnt/artix/envvars

# Show variables to confirm
cat /mnt/artix/envvars
echo -n "Is everything all right? Press anything to continue..."
read response

# Speed up pacman downloads and enable color mode
sed -i "s/^#\(Color\)/\1/" /etc/pacman.conf
sed -i "s/^#\(Parallel.*= \).*/\18/" /etc/pacman.conf

# Enable ntpd to synchronize time
dinitctl start ntpd

# Make sure all packages are up to date
pacman -Sy --noconfirm artix-keyring

# Base install
basestrap /mnt base base-devel dinit elogind-dinit linux linux-firmware linux-headers

# Generate fstab
fstabgen -L /mnt >> /mnt/etc/fstab

# Run install-2.sh inside the chroot environment
artix-chroot /mnt /artix/install-2.sh

# Restart system
rm -rf /mnt/artix
