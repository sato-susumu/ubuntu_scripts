#!/bin/bash

# This script is based on the method described in:
# https://qiita.com/tetutaro/items/17c0305b4e3e90e80ed7

wget https://dl.google.com/linux/direct/chrome-remote-desktop_current_amd64.deb 
sudo apt install -y xvfb xserver-xorg-video-dummy xbase-clients python3-packaging python3-psutil libutempter0
sudo dpkg -i chrome-remote-desktop_current_amd64.deb
sudo apt update
rm chrome-remote-desktop_current_amd64.deb
mkdir -p ~/.config/chrome-remote-desktop/

echo "Additional procedures are required. Please check the following pages for more details."
echo "https://remotedesktop.google.com/access"
echo "https://www.fujimiya-san.com/archives/1471"
