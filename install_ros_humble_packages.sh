#!/bin/bash

# This script is based on the method described in:
# https://zenn.dev/tasada038/articles/0a69eb6c6b444f

sudo apt update
sudo apt install -y ros-humble-gazebo-*
sudo apt install -y ros-humble-cartographer
sudo apt install -y ros-humble-cartographer-ros
sudo apt install -y ros-humble-navigation2
sudo apt install -y ros-humble-nav2-bringup
sudo apt install -y ros-humble-xacro

sudo apt install -y ros-humble-dynamixel-sdk
sudo apt install -y ros-humble-turtlebot3
sudo apt install -y ros-humble-turtlebot3-msgs
sudo apt install -y ros-humble-turtlebot3-gazebo
sudo apt install -y ros-humble-turtlebot3-fake-node
sudo apt install -y ros-humble-realsense2-camera


echo "export TURTLEBOT3_MODEL=burger" >> ~/.bashrc
echo "export LDS_MODEL=LDS-01" >> ~/.bashrc
source ~/.bashrc

