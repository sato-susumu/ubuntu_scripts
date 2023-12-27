#!/bin/bash

current_user=$(whoami)

sudo cp /etc/samba/smb.conf.backup /etc/samba/smb.conf

sudo smbpasswd -x $current_user

sudo systemctl restart smbd

echo "Samba configuration has been reset to its original state."

