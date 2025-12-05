#!/bin/bash

# xrdp installation script
# Connects RDP to existing X display via VNC (x0vncserver)
# Requires install_vnc.sh to be run first
# ※LAN内での使用を想定

set -e

echo "Disabling GNOME Remote Desktop..."
systemctl --user stop gnome-remote-desktop.service 2>/dev/null || true
systemctl --user disable gnome-remote-desktop.service 2>/dev/null || true
grdctl rdp disable 2>/dev/null || true

# Check if x0vncserver is running
if ! systemctl --user is-active x0vncserver.service >/dev/null 2>&1; then
    echo "x0vncserver is not running. Please run install_vnc.sh first."
    exit 1
fi

echo "Installing xrdp..."
sudo apt-get update
sudo apt-get install -y xrdp

# Add xrdp user to ssl-cert group
sudo adduser xrdp ssl-cert

# Configure xrdp to use VNC backend
echo "Configuring xrdp to connect to VNC..."
sudo tee /etc/xrdp/xrdp.ini > /dev/null << 'EOF'
[Globals]
ini_version=1
fork=true
port=3389
use_vsock=false
tcp_nodelay=true
tcp_keepalive=true
security_layer=negotiate
crypt_level=high
certificate=
key_file=
ssl_protocols=TLSv1.2, TLSv1.3
autorun=
allow_channels=true
allow_multimon=true
bitmap_cache=true
bitmap_compression=true
bulk_compression=true
max_bpp=32
new_cursors=true
use_fastpath=both

[Logging]
LogFile=xrdp.log
LogLevel=DEBUG
EnableSyslog=true
SyslogLevel=DEBUG

[Channels]
rdpdr=true
rdpsnd=true
drdynvc=true
cliprdr=true
rail=false
xrdpvr=true
tcutils=true

[vnc-any]
name=Current Desktop
lib=libvnc.so
ip=127.0.0.1
port=5900
username=na
password=

[Xorg]
name=Xorg (New Session)
lib=libxup.so
username=ask
password=ask
ip=127.0.0.1
port=-1
code=20
EOF

# Enable and start xrdp service
echo "Enabling xrdp service..."
sudo systemctl enable xrdp
sudo systemctl restart xrdp

echo ""
echo "xrdp installed and configured successfully!"
echo ""
echo "Connect with RDP client:"
echo "  $(hostname -I | awk '{print $1}'):3389"
echo ""
echo "At login screen, select 'Current Desktop' to view existing screen."
echo ""
echo "Service commands:"
echo "  sudo systemctl status xrdp"
echo "  sudo systemctl restart xrdp"
