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

# navigation
sudo apt install -y ros-humble-navigation2 ros-humble-nav2-bringup
sudo apt install -y ros-humble-cartographer ros-humble-cartographer-rviz

# tb3
sudo apt install -y ros-humble-dynamixel-sdk ros-humble-turtlebot3*

# tf
sudo apt install -y ros-humble-rqt-tf-tree

# rclpy
sudo apt install -y python3-sphinx python3-sphinx-autodoc-typehints python3-sphinx-rtd-theme

# Check if TURTLEBOT3_MODEL environment variable is set in ~/.bashrc, and add if not present
if ! grep -q "export TURTLEBOT3_MODEL=" ~/.bashrc; then
    echo "export TURTLEBOT3_MODEL=burger" >> ~/.bashrc
fi

# Check if LDS_MODEL environment variable is set in ~/.bashrc, and add if not present
if ! grep -q "export LDS_MODEL=" ~/.bashrc; then
    echo "export LDS_MODEL=LDS-01" >> ~/.bashrc
fi

if ! grep -q "export GAZEBO_MODEL_PATH=" ~/.bashrc; then
    echo "export GAZEBO_MODEL_PATH=$GAZEBO_MODEL_PATH:/opt/ros/humble/share/turtlebot3_gazebo/models" >> ~/.bashrc
fi

