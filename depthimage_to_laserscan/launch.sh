#!/bin/bash

launch_command() {
    xterm -T "$2" -e bash -c "echo Running $2; $1; exec bash" &
}

launch_command "ros2 run tf2_ros static_transform_publisher 0 0 0 0 0 0 map odom" "odom"
launch_command "ros2 run tf2_ros static_transform_publisher 0 0 0 0 0 0 odom base_link" "base_lin"
launch_command "ros2 run tf2_ros static_transform_publisher 0 0 0 0 0 0 base_link camera_link" "camera_link"


launch_command "ros2 launch realsense2_camera rs_launch.py pointcloud.enable:=true disparity_filter.enable:=true spatial_filter.enable:=true temporal_filter.enable:=true hole_filling_filter.enable:=truedecimation_filter.enable:=true" "realsense2_camera"

launch_command "ros2 topic hz /scan" "topic hz scan"

launch_command "ros2 launch depthimage_to_laserscan depthimage_to_laserscan-launch.py"
launch_command "ros2 run rqt_image_view rqt_image_view" "rqt_image_view"
launch_command "rqt_graph" "rqt_graph"
launch_command "rviz2 -d depthimage_to_laserscan.rviz" "rviz2"
launch_command "ros2 run rqt_tf_tree rqt_tf_tree --force-discover" "rqt_tf_tree"

# Wait for key input
read -p "Press any key to exit all xterm windows..."

# Kill all xterm processes
killall xterm
