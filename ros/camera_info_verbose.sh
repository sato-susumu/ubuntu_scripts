#!/bin/bash

echo "ls -l /dev/video*"
ls -l /dev/video*

echo ""
echo "cat /etc/group | grep video"
cat /etc/group | grep video

echo ""
echo "lsusb"
lsusb

echo ""
echo "v4l2-ctl --list-formats-ext"
v4l2-ctl --list-formats-ext
