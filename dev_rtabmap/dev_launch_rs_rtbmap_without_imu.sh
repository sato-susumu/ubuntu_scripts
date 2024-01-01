#!/bin/bash

# Function to execute a command in a new xterm window
launch_command() {
    xterm -T "$2" -e bash -c "echo Running $2; $1; exec bash" &
}

# Execute the commands in new xterm windows

# For details, please refer to the URL below.
# https://qiita.com/porizou1/items/1a2ca3a80c72a25289c9


launch_command "ros2 launch realsense2_camera rs_launch.py align_depth.enable:=true" "realsense"
launch_command "ros2 launch rtabmap_launch rtabmap.launch.py frame_id:=camera_link args:="-d" rgb_topic:=/camera/color/image_raw depth_topic:=/camera/aligned_depth_to_color/image_raw camera_info_topic:=/camera/color/camera_info approx_sync:=true
" "rtbmap"
launch_command "echo 'nodes:'; ros2 node list; echo ''; echo 'topics:'; ros2 topic list -t; echo ''; sleep 3; nvidia-smi" "ros2 command"

# Wait for key input
read -p "Press any key to exit all xterm windows..."

# Kill all xterm processes
killall xterm
