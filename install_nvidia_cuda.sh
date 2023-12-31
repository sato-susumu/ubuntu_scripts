#!/bin/bash

# This script is based on the method described in:
# https://zenn.dev/pon_pokapoka/articles/nvidia_cuda_install

cuda_version="12-1"

wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/cuda-keyring_1.0-1_all.deb
sudo dpkg -i cuda-keyring*.deb
sudo apt update

sudo apt list -a cuda

echo "Please check the following page for the appropriate version."
echo "  https://docs.nvidia.com/deeplearning/cudnn/support-matrix/index.html"

echo ""
echo "install version:"
echo "cuda_version=${cuda_version}"

read -p "Press any key to install"

sudo apt install -y cuda-${cuda_version}

# Store the configurations in variables
PATH_UPDATE="export PATH=\"/usr/local/cuda/bin\${PATH:+:\${PATH}}\""
LD_LIBRARY_PATH_UPDATE="export LD_LIBRARY_PATH=\"/usr/local/cuda/lib64\${LD_LIBRARY_PATH:+:\${LD_LIBRARY_PATH}}\""

# Check and append PATH configuration
if ! grep -Fxq "$PATH_UPDATE" ~/.bashrc; then
    echo "$PATH_UPDATE" >> ~/.bashrc
    echo "PATH configuration has been added to .bashrc."
else
    echo "PATH configuration already exists in .bashrc."
fi

# Check and append LD_LIBRARY_PATH configuration
if ! grep -Fxq "$LD_LIBRARY_PATH_UPDATE" ~/.bashrc; then
    echo "$LD_LIBRARY_PATH_UPDATE" >> ~/.bashrc
    echo "LD_LIBRARY_PATH configuration has been added to .bashrc."
else
    echo "LD_LIBRARY_PATH configuration already exists in .bashrc."
fi

source ~/.bashrc

echo ""
echo "nvcc -V"
nvcc -V

rm cuda-keyring*.deb
