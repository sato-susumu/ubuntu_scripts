#!/bin/bash

./launch_camera.sh

launch_command() {
    gnome-terminal --tab -- bash -c "$1; exec bash"
}

launch_command 'ros2 run rqt_image_view rqt_image_view'
launch_command 'ros2 topic hz /image_raw'
launch_command 'ros2 topic bw /image_raw'
