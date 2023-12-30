#!/bin/bash

launch_command() {
    gnome-terminal --tab -- bash -c "$1; exec bash"
}

launch_command 'ros2 launch nav2_bringup tb3_simulation_launch.py headless:=False'
