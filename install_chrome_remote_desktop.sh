#!/bin/bash

# This script is based on the method described in:
# https://qiita.com/tetutaro/items/17c0305b4e3e90e80ed7
# https://tech.nkhn37.net/ubuntu-xrdp-remove-dialog/

wget https://dl.google.com/linux/direct/chrome-remote-desktop_current_amd64.deb 
sudo apt install -y xvfb xserver-xorg-video-dummy xbase-clients python3-packaging python3-psutil # butempter0
sudo apt install -y libutempter0
sudo dpkg -i chrome-remote-desktop_current_amd64.deb
sudo apt update
rm chrome-remote-desktop_current_amd64.deb
mkdir -p ~/.config/chrome-remote-desktop/

echo "Additional procedures are required. Please check the following pages for more details."
echo "https://remotedesktop.google.com/access"
echo "https://www.fujimiya-san.com/archives/1471"

# Update pkaction config
required_pkaction_version="0.105"
version=$(pkaction --version | awk '{print $3}')
if [ "$version" = "$required_pkaction_version" ]; then
    # The version is correct, proceed with the script

    # Check if the file exists and remove it if it does
    if [ -f /etc/polkit-1/localauthority.conf.d/02-allow-colord.conf ]; then
        sudo rm /etc/polkit-1/localauthority.conf.d/02-allow-colord.conf
    fi

    # Create a new policy file only if it does not already exist
    if [ ! -f /etc/polkit-1/localauthority/50-local.d/45-allow-colord.pkla ]; then
        sudo tee /etc/polkit-1/localauthority/50-local.d/45-allow-colord.pkla > /dev/null <<EOF
[Allow Colord all Users]
Identity=unix-user:*
Action=org.freedesktop.color-manager.create-device;org.freedesktop.color-manager.create-profile;org.freedesktop.color-manager.delete-device;org.freedesktop.color-manager.delete-profile;org.freedesktop.color-manager.modify-device;org.freedesktop.color-manager.modify-profile
ResultAny=no
ResultInactive=no
ResultActive=yes
EOF
    fi

    # Restart the polkit service
    sudo systemctl restart polkit.service
fi
