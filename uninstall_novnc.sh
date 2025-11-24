#!/bin/bash

# noVNC uninstallation script

set -e

echo "Stopping user services..."
systemctl --user stop novnc-websockify 2>/dev/null || true
systemctl --user stop x11vnc 2>/dev/null || true

echo "Disabling user services..."
systemctl --user disable novnc-websockify 2>/dev/null || true
systemctl --user disable x11vnc 2>/dev/null || true

echo "Removing user service files..."
rm -f ~/.config/systemd/user/x11vnc.service
rm -f ~/.config/systemd/user/novnc-websockify.service
systemctl --user daemon-reload

# Also clean up any system services if they exist
echo "Cleaning up system services (if any)..."
sudo systemctl stop novnc-websockify x11vnc 2>/dev/null || true
sudo systemctl disable novnc-websockify x11vnc 2>/dev/null || true
sudo rm -f /etc/systemd/system/x11vnc.service
sudo rm -f /etc/systemd/system/novnc-websockify.service
sudo systemctl daemon-reload

echo "Uninstalling noVNC and related packages..."
sudo apt-get remove -y \
    novnc \
    websockify \
    python3-websockify \
    x11vnc

echo "Cleaning up..."
sudo apt-get autoremove -y

echo "noVNC uninstalled successfully!"
