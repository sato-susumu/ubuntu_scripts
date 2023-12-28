#!/bin/bash

launch_command() {
    gnome-terminal --tab -- bash -c "$1; exec bash"
}

launch_command 'ros2 launch turtlebot3_fake_node turtlebot3_fake_node.launch.py'
launch_command 'ros2 run turtlebot3_teleop teleop_keyboard'
