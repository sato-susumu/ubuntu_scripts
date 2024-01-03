#!/bin/bash

# Function to execute a command in a new xterm window
launch_command() {
    xterm -T "$2" -e bash -c "echo Running $2; $1; exec bash" &
}

# Execute the commands in new xterm windows

# For details, please refer to the URL below.
# https://qiita.com/porizou1/items/1a2ca3a80c72a25289c9


launch_command 'ros2 launch realsense2_camera rs_launch.py pointcloud.enable:=true disparity_filter.enable:=true spatial_filter.enable:=true temporal_filter.enable:=true hole_filling_filter.enable:=truedecimation_filter.enable:=true enable_gyro:=true enable_accel:=true unite_imu_method:=1 enable_sync:=true depth_module.profile:="640,480,30" rgb_camera.profile:="640,480,30"' "realsense2_camera"
launch_command "ros2 launch rtabmap_examples realsense_d435i_color.launch.py" "rtbmap"
launch_command "echo 'nodes:'; ros2 node list; echo ''; echo 'topics:'; ros2 topic list -t; echo ''; sleep 3; nvidia-smi" "ros2 command"

# Wait for key input
read -p "Press any key to exit all xterm windows..."

# Kill all xterm processes
killall xterm
