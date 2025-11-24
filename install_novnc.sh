#!/bin/bash

# noVNC installation script
# noVNC allows VNC access through a web browser
# Automatically starts on boot (user service)

set -e

echo "Installing noVNC and dependencies..."

# Install dependencies
sudo apt-get update
sudo apt-get install -y \
    novnc \
    websockify \
    python3-websockify \
    x11vnc

# Create user systemd directory
mkdir -p ~/.config/systemd/user

# Create user x11vnc service
echo "Creating x11vnc user service..."
cat > ~/.config/systemd/user/x11vnc.service << 'EOF'
[Unit]
Description=x11vnc VNC Server
After=graphical-session.target

[Service]
Type=simple
ExecStart=/usr/bin/x11vnc -display :0 -forever -shared -rfbport 5900 -nopw
Restart=on-failure
RestartSec=3

[Install]
WantedBy=default.target
EOF

# Create user noVNC websockify service
echo "Creating noVNC websockify user service..."
cat > ~/.config/systemd/user/novnc-websockify.service << 'EOF'
[Unit]
Description=noVNC Websocket Proxy
After=x11vnc.service
Requires=x11vnc.service

[Service]
Type=simple
ExecStart=/usr/bin/websockify --web=/usr/share/novnc/ 6080 localhost:5900
Restart=on-failure
RestartSec=3

[Install]
WantedBy=default.target
EOF

# Reload user systemd and enable services
echo "Enabling services to start on login..."
systemctl --user daemon-reload
systemctl --user enable x11vnc.service
systemctl --user enable novnc-websockify.service

# Start services now
echo "Starting services..."
systemctl --user start x11vnc.service
systemctl --user start novnc-websockify.service

# Enable lingering so services start at boot (before login)
echo "Enabling lingering for auto-start on boot..."
sudo loginctl enable-linger $USER

echo ""
echo "noVNC installed and configured successfully!"
echo ""
echo "Services are now running and will start automatically on boot."
echo ""
echo "Access via browser:"
echo "  http://localhost:6080/vnc.html"
echo "  http://$(hostname -I | awk '{print $1}'):6080/vnc.html"
echo ""
echo "Service commands:"
echo "  systemctl --user status x11vnc"
echo "  systemctl --user status novnc-websockify"
