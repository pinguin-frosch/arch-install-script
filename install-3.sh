#!/bin/bash

# Exit in case of any error
set -e

# Enable audio services
dinitctl enable pipewire
dinitctl enable pipewire-pulse
dinitctl enable wireplumber

# Install aur packages
yay -S --noconfirm --needed - < $HOME/Programming/aur/aur.txt
