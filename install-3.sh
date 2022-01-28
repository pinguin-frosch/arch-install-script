#!/bin/bash

# Opentablerdriver
systemctl --user enable --now opentabletdriver.service
echo "blacklist hid_uclogic" >> /etc/modprobe.d/blacklist.conf
rmmod hid_uclogic

# Eliminar
rm -rf ./install-3.sh
