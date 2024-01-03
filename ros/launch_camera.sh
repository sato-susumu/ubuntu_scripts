#!/bin/bash

# Function to start ROS node if the device exists
start_ros_node_if_device_exists() {
    if [ -e "/dev/$1" ]; then
        gnome-terminal --tab -- bash -c "ros2 run v4l2_camera v4l2_camera_node --ros-args -p video_device:=/dev/$1; exec bash"
    else
        echo "/dev/$1 does not exist"
    fi
}

# Check for the existence of devices and start ROS nodes
# start_ros_node_if_device_exists "video0"
# start_ros_node_if_device_exists "video2"
# start_ros_node_if_device_exists "video4"
start_ros_node_if_device_exists "video6"
# start_ros_node_if_device_exists "video8"
# start_ros_node_if_device_exists "device10"

