#!/bin/bash

launch_command() {
    gnome-terminal --tab -- bash -c "$1; exec bash"
}

launch_command 'ros2 launch turtlebot3_gazebo turtlebot3_world.launch.py'

# launch_command 'ros2 launch turtlebot3_navigation2 navigation2.launch.py use_sim_time:=True map:=$HOME/map.yaml'
launch_command 'ros2 launch turtlebot3_navigation2 navigation2.launch.py use_sim_time:=True slam:=True'
launch_command 'ros2 run turtlebot3_teleop teleop_keyboard'

echo "save map"
echo "   ros2 run nav2_map_server map_saver_cli -f ~/map"
