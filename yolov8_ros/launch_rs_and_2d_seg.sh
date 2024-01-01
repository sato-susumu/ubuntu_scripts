#!/bin/bash

# Check if xterm is installed and install it if not
if ! command -v xterm &> /dev/null; then
    echo "xterm is not installed. Installing xterm..."
    sudo apt-get update && sudo apt-get install -y xterm
fi

# Function to execute a command in a new xterm window
launch_command() {
    xterm -T "$2" -e bash -c "echo Running $2; $1; exec bash" &
}

# Execute the commands in new xterm windows

# For details, please refer to the URL below.
# https://github.com/IntelRealSense/realsense-ros
# https://github.com/mgonzs13/yolov8_ros

source ~/yolov8_ros/install/setup.bash

launch_command "ros2 launch realsense2_camera rs_launch.py enable_rgbd:=true enable_sync:=true align_depth.enable:=false enable_color:=true enable_depth:=true" "RealSense Camera"
launch_command "ros2 launch yolov8_bringup yolov8.launch.py input_image_topic:=/camera/color/image_raw model:=yolov8m-seg.pt" "YoloV8"
launch_command "ros2 run rqt_image_view rqt_image_view" "rqt_image_view"
launch_command "rqt_graph" "rqt_graph"
launch_command "echo 'nodes:'; ros2 node list; echo ''; echo 'topics:'; ros2 topic list -t; echo ''; sleep 3; nvidia-smi" "ros2 command"
launch_command "ros2 topic hz /camera/color/image_raw" "topic hz image_raw"
launch_command "ros2 topic hz /yolo/dbg_image" "topic hz dbg_image"

# Wait for key input
read -p "Press any key to exit all xterm windows..."

# Kill all xterm processes
killall xterm
