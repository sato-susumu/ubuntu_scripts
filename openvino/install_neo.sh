#!/bin/bash

mkdir -p neo && cd neo
sudo apt update
sudo apt upgrade -y
wget https://github.com/intel/intel-graphics-compiler/releases/download/igc-1.0.15136.4/intel-igc-core_1.0.15136.4_amd64.deb
wget https://github.com/intel/intel-graphics-compiler/releases/download/igc-1.0.15136.4/intel-igc-opencl_1.0.15136.4_amd64.deb
wget https://github.com/intel/compute-runtime/releases/download/23.35.27191.9/intel-level-zero-gpu-dbgsym_1.3.27191.9_amd64.ddeb
wget https://github.com/intel/compute-runtime/releases/download/23.35.27191.9/intel-level-zero-gpu_1.3.27191.9_amd64.deb
wget https://github.com/intel/compute-runtime/releases/download/23.35.27191.9/intel-opencl-icd-dbgsym_23.35.27191.9_amd64.ddeb
wget https://github.com/intel/compute-runtime/releases/download/23.35.27191.9/intel-opencl-icd_23.35.27191.9_amd64.deb
wget https://github.com/intel/compute-runtime/releases/download/23.35.27191.9/libigdgmm12_22.3.11.ci17747749_amd64.deb
sudo dpkg -i *.deb
cd ..
