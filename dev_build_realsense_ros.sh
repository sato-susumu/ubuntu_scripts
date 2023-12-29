#!/bin/bash

# This script is based on the method described in:

# https://github.com/IntelRealSense/realsense-ros

mkdir -p ~/realsense_ws/src
cd ~/realsense_ws/src/
git clone https://github.com/IntelRealSense/realsense-ros.git -b ros2-development
cd ~/realsense_ws
sudo apt-get install python3-rosdep -y
sudo rosdep init # "sudo rosdep init --include-eol-distros" for Foxy and earlier
rosdep update # "sudo rosdep update --include-eol-distros" for Foxy and earlier
rosdep install -i --from-path src --rosdistro $ROS_DISTRO --skip-keys=librealsense2 -y
# colcon build --symlink-install
colcon build
source /opt/ros/humble/setup.bash

echo "install:"
cd ~/realsense_ws
. install/local_setup.bash
