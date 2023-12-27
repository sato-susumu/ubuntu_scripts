#!/bin/bash

# This script is based on the method described in:
# https://qiita.com/TakanoTaiga/items/0c6d198fdb4ffab5dd04

sudo apt update
sudo apt upgrade -y
sudo apt install git curl
git clone https://github.com/autowarefoundation/autoware.git -b main --single-branch
cd autoware
./setup-dev-env.sh

nvidia-smi
nvcc --version
dpkg -l | grep TensorRT
cat /usr/include/cudnn_version.h | grep "#define CUDNN_MAJOR" -A 2

echo $ROS_DISTRO
