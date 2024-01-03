#!/bin/bash

sudo apt update
sudo apt upgrade -y
sudo apt --fix-missing update
sudo apt --fix-broken install
sudo apt install -y python3-pip python3-venv
python3 -m pip install -U pip setuptools
python3 -m pip install --upgrade pip
python3 -m venv venv-ov22.3
source venv-ov22.3/bin/activate
python3 -m pip install -U pip setuptools
python3 -m pip install --upgrade pip
python3 -m pip install openvino==2022.3.0 openvino-dev[tensorflow2,pytorch,caffe,onnx,mxnet,kaldi]==2022.3.0
