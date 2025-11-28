#!/bin/bash

# TigerVNC (x0vncserver) installation script
# Allows VNC access to the current X display
# Automatically starts on boot (user service)
# ※LAN内での使用を想定

set -e

echo "Installing TigerVNC..."

# Install TigerVNC
sudo apt-get update
sudo apt-get install -y tigervnc-scraping-server

# Create user systemd directory
mkdir -p ~/.config/systemd/user

# Create user x0vncserver service
echo "Creating x0vncserver user service..."
cat > ~/.config/systemd/user/x0vncserver.service << 'EOF'
[Unit]
Description=TigerVNC x0vncserver
After=graphical-session.target

[Service]
Type=forking
ExecStart=/usr/bin/x0vncserver -display :0 -rfbport 5900 -SecurityTypes None
Restart=on-failure
RestartSec=3

[Install]
WantedBy=default.target
EOF

# Reload user systemd and enable service
echo "Enabling service to start on login..."
systemctl --user daemon-reload
systemctl --user enable x0vncserver.service

# Start service now
echo "Starting service..."
systemctl --user start x0vncserver.service

# Enable lingering so service starts at boot (before login)
echo "Enabling lingering for auto-start on boot..."
sudo loginctl enable-linger $USER

echo ""
echo "TigerVNC x0vncserver installed and configured successfully!"
echo ""
echo "Service is now running and will start automatically on boot."
echo ""
echo "Connect with VNC client:"
echo "  localhost:5900"
echo "  $(hostname -I | awk '{print $1}'):5900"
echo ""
echo "Service commands:"
echo "  systemctl --user status x0vncserver"
echo "  systemctl --user restart x0vncserver"
