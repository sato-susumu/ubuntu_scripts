#!/bin/bash

sudo apt update
sudo apt install -y samba

current_user=$(whoami)

if grep -q "^\[$current_user\]" /etc/samba/smb.conf; then
    echo "The share for $current_user already exists in /etc/samba/smb.conf."
else
    sudo cp /etc/samba/smb.conf /etc/samba/smb.conf.backup

    echo "Adding Samba share configuration for $current_user."
    echo "[$current_user]
    path = /home/$current_user
    read only = no
    browsable = yes
    guest ok = no
    writable = yes
    create mask = 0700
    directory mask = 0700" | sudo tee -a /etc/samba/smb.conf
fi

sudo smbpasswd -a $current_user
sudo systemctl restart smbd

echo "Samba setup complete for the home directory of $current_user."

sudo systemctl status smbd --no-pager
sudo systemctl status nmbd --no-pager

server_hostname=$(hostname)
echo "To access the shared folder from Windows, open Explorer and navigate to:"
echo "\\\\${server_hostname}\\${current_user}"
