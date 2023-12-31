#!/bin/bash

# This script is based on the method described in:
# https://zenn.dev/pon_pokapoka/articles/nvidia_cuda_install

wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/cuda-keyring_1.1-1_all.deb
sudo dpkg -i cuda-keyring_1.1-1_all.deb
sudo apt update
sudo apt install cuda-drivers
# nvidia-smi

read -p "Press any key to reboot"
sudo reboot
