#!/bin/bash

# Check if the exact line is already in .bashrc
if ! grep -qx "export PATH=\$PATH:." ~/.bashrc; then
    # Add the current folder to .bashrc
    echo "export PATH=\$PATH:." >> ~/.bashrc
    echo "Current folder has been added to .bashrc."
else
    echo "Current folder is already in .bashrc."
fi
