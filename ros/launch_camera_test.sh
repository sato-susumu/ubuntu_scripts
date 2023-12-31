#!/bin/bash

launch_command() {
    xterm -T "$2" -e bash -c "echo Running $2; $1; exec bash" &
}

launch_command "ros2 run v4l2_camera v4l2_camera_node --ros-args -p video_device:=/dev/video6" "v4l2_camera node"
launch_command "ros2 topic hz /image_raw" "topic hz image_raw"
launch_command "ros2 run rqt_image_view rqt_image_view" "rqt_image_view"

# Wait for key input
read -p "Press any key to exit all xterm windows..."

# Kill all xterm processes
killall xterm
