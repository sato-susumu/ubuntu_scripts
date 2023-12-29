#!/bin/bash

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
sudo apt install -y ros-humble-nav2-amcl

# joystick
sudo apt install -y ros-humble-joy*

# realsense ros2 wrapper
sudo apt install -y ros-humble-librealsense2 ros-humble-realsense2-camera

# camera
sudo apt install -y ros-humble-v4l2-camera

# Check if TURTLEBOT3_MODEL environment variable is set in ~/.bashrc, and add if not present
if ! grep -q "export TURTLEBOT3_MODEL=" ~/.bashrc; then
    echo "export TURTLEBOT3_MODEL=burger" >> ~/.bashrc
fi

# Check if LDS_MODEL environment variable is set in ~/.bashrc, and add if not present
if ! grep -q "export LDS_MODEL=" ~/.bashrc; then
    echo "export LDS_MODEL=LDS-01" >> ~/.bashrc
fi
