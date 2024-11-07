sudo bash -c 'cat > /etc/polkit-1/localauthority/50-local.d/45-allow-colord.pkla <<EOL
[Allow Colord all Users]
Identity=unix-user:*
Action=org.freedesktop.color-manager.create-device;org.freedesktop.color-manager.create-profile;org.freedesktop.color-manager.delete-device;org.freedesktop.color-manager.delete-profile;org.freedesktop.color-manager.modify-device
ResultAny=no
ResultInactive=no
ResultActive=yes

[Allow Package Management all Users]
Identity=unix-user:*
Action=org.debian.apt.*;io.snapcraft.*;org.freedesktop.packagekit.*;com.ubuntu.*
ResultAny=yes
ResultInactive=yes
ResultActive=yes

[Allow WiFi Scan all Users]
Identity=unix-user:*
Action=org.freedesktop.NetworkManager.wifi.scan
ResultAny=yes
ResultInactive=yes
ResultActive=yes
EOL
sudo systemctl restart NetworkManager'
