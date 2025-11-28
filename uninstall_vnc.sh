#!/bin/bash

# TigerVNC (x0vncserver) uninstallation script

set -e

echo "Stopping user service..."
systemctl --user stop x0vncserver 2>/dev/null || true

echo "Disabling user service..."
systemctl --user disable x0vncserver 2>/dev/null || true

echo "Removing user service file..."
rm -f ~/.config/systemd/user/x0vncserver.service
systemctl --user daemon-reload

echo "Uninstalling TigerVNC..."
sudo apt-get remove -y tigervnc-scraping-server

echo "Cleaning up..."
sudo apt-get autoremove -y

echo "TigerVNC uninstalled successfully!"
