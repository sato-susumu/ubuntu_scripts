#!/bin/bash

# docker run --shm-size=512m --net=host --privileged tiryoh/ros2-desktop-vnc:humble
docker run -p 6080:80 --name humble_vnc --shm-size=512m --privileged tiryoh/ros2-desktop-vnc:humble

