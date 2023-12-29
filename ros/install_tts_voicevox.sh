#!/bin/bash

# This script is based on the method described in:
# https://github.com/HansRobo/speak_ros_voicevox_plugin

mkdir -p ~/speak_ros_ws/src
cd ~/speak_ros_ws/src
git clone https://github.com/HansRobo/speak_ros
git clone https://github.com/HansRobo/speak_ros_voicevox_plugin
cd ..
source /opt/ros/humble/setup.bash
rosdep install -riy --from-paths src
colcon build --symlink-install
