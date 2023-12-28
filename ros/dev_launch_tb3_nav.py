#!/bin/bash

launch_command() {
    gnome-terminal --tab -- bash -c "$1; exec bash"
}

launch_command 'ros2 launch turtlebot3_gazebo turtlebot3_world.launch.py'
launch_command 'ros2 launch turtlebot3_bringup turtlebot3_state_publisher.launch.py'
launch_command 'ros2 run turtlebot3_teleop teleop_keyboard'
launch_command 'ros2 launch turtlebot3_cartographer cartographer.launch.py use_sim_time:=True'
