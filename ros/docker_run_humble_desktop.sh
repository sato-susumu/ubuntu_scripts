#!/bin/bash

docker run -it --rm --name humble_desktop \
    --net=host \
    --privileged \
    --device=/dev/video0:/dev/video0 \
    osrf/ros:humble-desktop \
    /bin/bash
