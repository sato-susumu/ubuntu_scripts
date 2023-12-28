#!/bin/bash

launch_command() {
    gnome-terminal --tab -- bash -c "$1; exec bash"
}

launch_command 'ros2 run turtlesim turtlesim_node'
launch_command 'ros2 run turtlesim turtle_teleop_key'
launch_command 'rqt_graph'
launch_command 'echo "nodes:";
ros2 node list;
echo "";
echo "topics:";
ros2 topic list -t;
echo "";
echo "ros2 node info /turtlesim:";
ros2 node info /turtlesim'
