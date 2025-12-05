#!/bin/bash

# xrdp uninstallation script

set -e

echo "Stopping xrdp service..."
sudo systemctl stop xrdp 2>/dev/null || true
sudo systemctl disable xrdp 2>/dev/null || true

echo "Uninstalling xrdp..."
sudo apt-get remove -y xrdp

echo "Cleaning up..."
sudo apt-get autoremove -y

echo ""
echo "xrdp uninstalled successfully!"
echo ""
echo "To re-enable GNOME Remote Desktop, run:"
echo "  systemctl --user enable gnome-remote-desktop.service"
echo "  systemctl --user start gnome-remote-desktop.service"
