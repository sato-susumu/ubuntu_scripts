#!/bin/bash

launch_command() {
    gnome-terminal --tab -- bash -c "$1; exec bash"
}

launch_command 'ros2 run demo_nodes_cpp talker'
launch_command 'ros2 run demo_nodes_cpp listener'
