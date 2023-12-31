#!/bin/bash

# This script is based on the method described in:
# https://docs.nvidia.com/deeplearning/cudnn/install-guide/index.html#package-manager-ubuntu-install

cuda_version="12.1"
cudnn_version="8.9.3.28"

sudo apt update

sudo apt list -a libcudnn8

echo "Please check the following page for the appropriate version."
echo "  https://docs.nvidia.com/deeplearning/cudnn/support-matrix/index.html"

echo ""
echo "install version:"
echo "cuda_version=${cuda_version}"
echo "cudnn_version=${cudnn_version}"

read -p "Press any key to install"

sudo apt install -y libcudnn8=${cudnn_version}-1+cuda${cuda_version}
sudo apt install -y libcudnn8-dev=${cudnn_version}-1+cuda${cuda_version}
sudo apt install -y libcudnn8-samples=${cudnn_version}-1+cuda${cuda_version}
