#!/bin/bash

# Retrieve the username from the environment variable
username=$USER

# Backup the sudoers file with overwrite option
sudo cp -f /etc/sudoers /etc/sudoers.bak

# Check if the setting already exists
if sudo grep -q "^${username} ALL=(ALL:ALL) NOPASSWD: ALL" /etc/sudoers; then
    echo "The setting already exists."
else
    # Append the setting to the sudoers file
    echo "${username} ALL=(ALL:ALL) NOPASSWD: ALL" | sudo tee -a /etc/sudoers > /dev/null
    echo "The setting has been added."
fi
