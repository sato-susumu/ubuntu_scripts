#!/bin/bash

launch_command() {
    gnome-terminal --tab -- bash -c "$1; exec bash"
}

# For details, please refer to the URL below.
# https://github.com/IntelRealSense/realsense-ros

source ~/yolov8_ros/install/setup.bash

launch_command 'ros2 launch realsense2_camera rs_launch.py enable_rgbd:=true enable_sync:=true align_depth.enable:=false enable_color:=true enable_depth:=true'

launch_command 'ros2 launch yolov8_bringup yolov8.launch.py input_image_topic:=/camera/color/image_raw'
launch_command 'ros2 run rqt_image_view rqt_image_view'
launch_command 'rqt_graph'
launch_command '(
echo "nodes:";
ros2 node list;
echo "";
echo "topics:";
ros2 topic list -t;
echo "";
)'


