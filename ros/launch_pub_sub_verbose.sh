#!/bin/bash

launch_command() {
    gnome-terminal --tab -- bash -c "$1; exec bash"
}

launch_command 'ros2 run demo_nodes_cpp talker'
launch_command 'ros2 run demo_nodes_cpp listener'
launch_command 'rqt_graph'
launch_command 'echo "nodes:";
ros2 node list;
echo "";
echo "topics:";
ros2 topic list -t;
echo "";
echo "/chatter topic info:";
ros2 topic info /chatter'

launch_command 'ros2 topic hz /chatter'
launch_command 'ros2 topic echo /chatter'
