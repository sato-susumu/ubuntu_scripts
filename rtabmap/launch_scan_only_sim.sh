#!/bin/bash

# Function to execute a command in a new xterm window
launch_command() {
    xterm -T "$2" -e bash -c "echo Running $2; $1; exec bash" &
}

# Execute the commands in new xterm windows

# For details, please refer to the URL below.
# https://qiita.com/porizou1/items/1a2ca3a80c72a25289c9

launch_command "ros2 launch turtlebot3_gazebo turtlebot3_world.launch.py" "gazebo"
launch_command "ros2 run turtlebot3_teleop teleop_keyboard" "keyop"
launch_command "echo 'nodes:'; ros2 node list; echo ''; echo 'topics:'; ros2 topic list -t; echo ''; sleep 3; nvidia-smi" "ros2 command"
launch_command "ros2 launch rtabmap_demos turtlebot3_scan.launch.py" "rtbmap"

# Wait for key input
read -p "Press any key to exit all xterm windows..."

# Kill all xterm processes
killall xterm
