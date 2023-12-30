#!/bin/bash

launch_command() {
    gnome-terminal --tab -- bash -c "$1; exec bash"
}

launch_command 'source ~/whisper_ros_ws/install/setup.bash; ros2 launch whisper_bringup whisper.launch.py'

