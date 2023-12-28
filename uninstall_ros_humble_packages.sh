#!/bin/bash

sudo apt update
sudo apt remove -y ros-humble-gazebo-*
sudo apt remove -y ros-humble-cartographer
sudo apt remove -y ros-humble-cartographer-ros
sudo apt remove -y ros-humble-navigation2
sudo apt remove -y ros-humble-nav2-bringup
sudo apt remove -y ros-humble-xacro

sudo apt remove -y ros-humble-dynamixel-sdk
sudo apt remove -y ros-humble-turtlebot3
sudo apt remove -y ros-humble-turtlebot3-msgs
sudo apt remove -y ros-humble-turtlebot3-gazebo
sudo apt remove -y ros-humble-turtlebot3-fake-node
sudo apt remove -y ros-humble-realsense2-camera
