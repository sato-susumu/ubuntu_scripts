#!/bin/bash

mkdir -p ~/yolov8_ros/src
cd ~/yolov8_ros/src
git clone https://github.com/mgonzs13/yolov8_ros.git
pip3 install -r yolov8_ros/requirements.txt
cd ~/yolov8_ros
rosdep install --from-paths src --ignore-src -r -y
colcon build
