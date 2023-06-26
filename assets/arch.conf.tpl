title Arch Linux
linux /vmlinuz-linux
initrd /initramfs-linux.img
options root=UUID=$arch_root_uuid rw
options resume=UUID=$arch_swap_uuid
