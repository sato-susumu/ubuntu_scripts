#!/bin/bash

launch_command() {
    gnome-terminal --tab -- bash -c "$1; exec bash"
}

launch_command 'docker run --rm --gpus all -p '127.0.0.1:50021:50021' voicevox/voicevox_engine:nvidia-ubuntu20.04-latest'
launch_command 'source ~/speak_ros_ws/install/setup.bash;ros2 run speak_ros speak_ros_node --ros-args -p plugin_name:=voicevox_plugin::VoiceVoxPlugin'

