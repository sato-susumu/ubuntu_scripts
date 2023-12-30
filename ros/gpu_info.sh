#!/bin/bash

echo 'dpkg -l | grep -iE "nvidia|cuda"'
dpkg -l | grep -iE "nvidia|cuda"

echo ""
echo "nvcc -V"
nvcc -V

echo ""
echo "nvidia-smi"
nvidia-smi
