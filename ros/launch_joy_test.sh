#!/bin/bash

launch_command() {
    gnome-terminal --tab -- bash -c "$1; exec bash"
}

echo "lsusb | grep -iE 'pad|joy'"
lsusb | grep -iE 'pad|joy'

echo ""
echo "ls -l /dev/input/js*"
ls -l /dev/input/js*

echo ""
launch_command 'ros2 run joy_linux joy_linux_node'
launch_command 'ros2 topic echo /joy'
# launch_command 'ros2 launch teleop_twist_joy teleop-launch.py joy_config:="xbox"'
launch_command 'ros2 launch teleop_twist_joy teleop-launch.py'
launch_command 'rqt_graph'
launch_command 'ros2 topic echo /cmd_vel'

echo "ros2 param set /teleop_twist_joy_node require_enable_button False"
ros2 param set /teleop_twist_joy_node require_enable_button False

echo "ros2 param get /teleop_twist_joy_node require_enable_button"
ros2 param get /teleop_twist_joy_node require_enable_button
