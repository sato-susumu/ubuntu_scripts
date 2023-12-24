#!/bin/bash

sudo apt update
sudo apt install python3-pip -y
pip3 install awscli --upgrade --user

if ! grep -q 'export PATH=$PATH:~/.local/bin' ~/.bashrc; then
    echo 'export PATH=$PATH:~/.local/bin' >> ~/.bashrc
fi

source ~/.bashrc
aws --version
