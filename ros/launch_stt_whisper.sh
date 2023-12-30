#!/bin/bash

launch_command() {
    gnome-terminal --tab -- bash -c "$1; exec bash"
}

launch_command 'source ~/speak_ros_ws/install/setup.bash;ros2 run speak_ros speak_ros_node --ros-args -p plugin_name:=voicevox_plugin::VoiceVoxPlugin'

launch_command 'source ~/whisper_ros_ws/install/setup.bash; ros2 launch whisper_bringup whisper.launch.py'

