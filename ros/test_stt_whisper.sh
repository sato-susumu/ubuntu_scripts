#!/bin/bash

launch_command() {
    gnome-terminal --tab -- bash -c "$1; exec bash"
}

launch_command 'ros2 topic echo /whisper/text'
launch_command 'source ~/whisper_ros_ws/install/setup.bash; ros2 action send_goal /whisper/listen whisper_msgs/action/STT "{}"'

