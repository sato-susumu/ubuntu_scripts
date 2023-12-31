#!/bin/bash

# This script is based on the method described in:
# https://zenn.dev/pon_pokapoka/articles/nvidia_cuda_install

sudo apt update
sudo apt install -y cuda-toolkit

# Store the configurations in variables
PATH_UPDATE="export PATH=\"/usr/local/cuda/bin\${PATH:+:\${PATH}}\""
LD_LIBRARY_PATH_UPDATE="export LD_LIBRARY_PATH=\"/usr/local/cuda/lib64\${LD_LIBRARY_PATH:+:\${LD_LIBRARY_PATH}}\""

# Path to the .bashrc file
BASHRC="~/.bashrc"

# Check and append PATH configuration
if ! grep -Fxq "$PATH_UPDATE" ~/.bashrc; then
    echo "$PATH_UPDATE" >> ~/.bashrc
    echo "PATH configuration has been added to .bashrc."
else
    echo "PATH configuration already exists in .bashrc."
fi

# Check and append LD_LIBRARY_PATH configuration
if ! grep -Fxq "$LD_LIBRARY_PATH_UPDATE" "$BASHRC"; then
    echo "$LD_LIBRARY_PATH_UPDATE" >> "$BASHRC"
    echo "LD_LIBRARY_PATH configuration has been added to .bashrc."
else
    echo "LD_LIBRARY_PATH configuration already exists in .bashrc."
fi
nvcc -v
