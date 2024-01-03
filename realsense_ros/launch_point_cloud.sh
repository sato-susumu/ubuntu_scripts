#!/bin/bash

launch_command() {
    xterm -T "$2" -e bash -c "echo Running $2; $1; exec bash" &
}

# For details, please refer to the URL below.
# https://github.com/IntelRealSense/realsense-ros

launch_command "ros2 run tf2_ros static_transform_publisher 0 0 0 0 0 0 map odom" "odom"
launch_command "ros2 run tf2_ros static_transform_publisher 0 0 0 0 0 0 odom base_link" "base_lin"
launch_command "ros2 run tf2_ros static_transform_publisher 0 0 0 0 0 0 base_link camera_link" "camera_link"
launch_command "ros2 launch realsense2_camera rs_launch.py pointcloud.enable:=true" "realsense2_camera"


launch_command '(
echo "nodes:";
ros2 node list;
echo "";
echo "topics:";
ros2 topic list -t;
echo "";
)' "ros2 command"

launch_command "ros2 topic hz /camera/color/image_raw" "topic hz image_raw"
launch_command "ros2 topic hz /camera/aligned_depth_to_color/image_raw" "topic hz aligned depth image_raw"
launch_command "ros2 topic hz /camera/depth/color/points" "topic hz points"

launch_command "rqt_graph" "rqt_graph"
launch_command "ros2 run rqt_tf_tree rqt_tf_tree --force-discover"
launch_command "ros2 run rqt_image_view rqt_image_view" "rqt_image_view"
launch_command "rviz2 -d launch_point_cloud.rviz" "rviz2"

# Wait for key input
read -p "Press any key to exit all xterm windows..."

# Kill all xterm processes
killall xterm
