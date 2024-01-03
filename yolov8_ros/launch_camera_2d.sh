#!/bin/bash

launch_command() {
    xterm -T "$2" -e bash -c "echo Running $2; $1; exec bash" &
}

source ~/yolov8_ros/install/setup.bash

launch_command "ros2 run v4l2_camera v4l2_camera_node --ros-args -p video_device:=/dev/video6" "v4l2_camera node"
launch_command "ros2 launch yolov8_bringup yolov8.launch.py input_image_topic:=/image_raw model:=$1" "YoloV8"
launch_command "ros2 topic hz /image_raw" "topic hz image_raw"
launch_command "ros2 topic hz /yolo/dbg_image" "topic hz dbg_image"
launch_command "ros2 run rqt_image_view rqt_image_view" "rqt_image_view"

# Wait for key input
read -p "Press any key to exit all xterm windows..."

# Kill all xterm processes
killall xterm
