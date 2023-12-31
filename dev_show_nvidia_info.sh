#!/bin/bash

echo "gpu:"
lspci | grep -i nvidia

echo ""
echo "nvidia driver:"
dpkg -l | grep nvidia

echo ""
echo "nvidia-smi"
nvidia-smi

echo ""
echo "CUDA:"
dpkg -l | grep cuda

echo ""
echo "nvcc -V"
nvcc -V

echo ""
echo "nvidia container toolkit"
dpkg -l | grep nvidia-container

echo ""
echo "cuDNN:"
cat /usr/include/cudnn.h | grep CUDNN_MAJOR -A 2

echo ""
echo "TensorFlowGPU:"
python3 -c "from tensorflow.python.client import device_lib; print(device_lib.list_local_devices())"

