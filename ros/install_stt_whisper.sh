#!/bin/bash

# This script is based on the method described in:
# https://github.com/mgonzs13/whisper_ros

sudo apt update
sudo apt install -y portaudio19-dev python3-venv

mkdir -p ~/whisper_ros_ws/src
cd ~/whisper_ros_ws/src
# python3 -m venv venv
# source ./venv/bin/activate
git clone https://github.com/mgonzs13/audio_common.git
git clone --recurse-submodules https://github.com/AGI4ROS/whisper_ros.git

# Installing dependencies
pip install -r audio_common/requirements.txt
pip install -r whisper_ros/requirements.txt

# Building the workspace
cd ~/whisper_ros_ws
colcon build

