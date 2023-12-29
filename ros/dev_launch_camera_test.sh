#!/bin/bash

launch_command() {
    gnome-terminal --tab -- bash -c "$1; exec bash"
}

launch_command 'ros2 run rqt_image_view rqt_image_view'
sleep 3
# launch_command 'ros2 run v4l2_camera v4l2_camera_node'
launch_command 'ros2 run v4l2_camera v4l2_camera_node --ros-args -p video_device:=/dev/video0'
