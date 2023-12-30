#!/bin/bash

sudo apt update

# joystick
sudo apt install -y ros-humble-joy*

# realsense ros2 wrapper
sudo apt install -y ros-humble-librealsense2 ros-humble-realsense2-camera

# camera
sudo apt install -y ros-humble-v4l2-camera

# simulation
sudo apt install -y ros-humble-gazebo-ros-pkgs ros-humble-ros-ign

# Check if TURTLEBOT3_MODEL environment variable is set in ~/.bashrc, and add if not present
if ! grep -q "export TURTLEBOT3_MODEL=" ~/.bashrc; then
    echo "export TURTLEBOT3_MODEL=burger" >> ~/.bashrc
fi

# Check if LDS_MODEL environment variable is set in ~/.bashrc, and add if not present
if ! grep -q "export LDS_MODEL=" ~/.bashrc; then
    echo "export LDS_MODEL=LDS-01" >> ~/.bashrc
fi
