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

launch_command "ros2 run tf2_ros static_transform_publisher 0 0 0 0 0 0 map odom" "odom"
launch_command "ros2 run tf2_ros static_transform_publisher 0 0 0 0 0 0 odom base_link" "base_lin"
launch_command "ros2 run tf2_ros static_transform_publisher 0 0 0 0 0 0 base_link camera_link" "camera_link"

launch_command "ros2 launch realsense2_camera rs_launch.py enable_sync:=true align_depth.enable:=true enable_color:=true enable_depth:=true pointcloud.enable:=true disparity_filter.enable:=true spatial_filter.enable:=true temporal_filter.enable:=true hole_filling_filter.enable:=truedecimation_filter.enable:=true" "realsense2_camera"
launch_command "ros2 launch yolov8_bringup yolov8_3d.launch.py input_image_topic:=/camera/color/image_raw input_depth_topic:=/camera/aligned_depth_to_color/image_raw input_depth_info_topic:=/camera/aligned_depth_to_color/camera_info model:=$1" "YoloV8 3D"
launch_command "echo 'nodes:'; ros2 node list; echo ''; echo 'topics:'; ros2 topic list -t; echo ''; sleep 3; nvidia-smi" "ros2 command"
launch_command "ros2 topic hz /camera/color/image_raw" "topic hz image_raw"
launch_command "ros2 topic hz /camera/aligned_depth_to_color/image_raw" "topic hz aligned depth image_raw"
launch_command "ros2 topic hz /yolo/dbg_image" "topic hz dbg_image"
# launch_command "ros2 run rqt_tf_tree rqt_tf_tree --force-discover"
# launch_command "rqt_graph" "rqt_graph"
launch_command "rviz2 -d launch_rs_and_3d.rviz" "rviz2"

# Wait for key input
read -p "Press any key to exit all xterm windows..."

# Kill all xterm processes
killall xterm
