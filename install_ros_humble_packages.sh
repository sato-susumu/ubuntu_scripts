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

sudo apt remove -y ros-humble-dynamixel-sdk
sudo apt remove -y ros-humble-turtlebot3-msgs
sudo apt remove -y ros-humble-turtlebot3*

sudo apt install -y ros-humble-turtlebot3-gazebo

mkdir -p ~/turtlebot3_ws/src
cd ~/turtlebot3_ws/src/
git clone -b humble-devel https://github.com/ROBOTIS-GIT/DynamixelSDK.git
git clone -b humble-devel https://github.com/ROBOTIS-GIT/turtlebot3_msgs.git
git clone -b humble-jp-devel https://github.com/ROBOTIS-JAPAN-GIT/turtlebot3_jp_custom.git
cd ~/turtlebot3_ws
colcon build --symlink-install
echo 'source ~/turtlebot3_ws/install/setup.bash' >> ~/.bashrc
source ~/.bashrc

sudo apt install -y ros-humble-realsense2-camera
cd ~/turtlebot3_ws/src
git clone -b humble-jp-devel https://github.com/ROBOTIS-JAPAN-GIT/realsense-ros_jp_custom
git clone -b foxy-devel https://github.com/pal-robotics/realsense_gazebo_plugin
cd ~/turtlebot3_ws
colcon build --symlink-install

cd ~/turtlebot3_ws/src/
git clone -b humble-jp-devel https://github.com/ROBOTIS-JAPAN-GIT/turtlebot3_simulations_jp_custom
git clone https://github.com/robotics-upo/lightsfm
cd lightsfm
make
sudo make install
cd ~/turtlebot3_ws
colcon build --symlink-install

echo "export TURTLEBOT3_MODEL=burger" >> ~/.bashrc
echo "export LDS_MODEL=LDS-01" >> ~/.bashrc
source ~/.bashrc

