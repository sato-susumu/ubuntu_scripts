#!/bin/bash

echo "ls -l /dev/video*"
ls -l /dev/video*

echo ""
echo "lsusb"
lsusb

echo ""
echo "sudo v4l2-ctl --list-devices"
v4l2-ctl --list-devices

echo ""
echo "cat /etc/group | grep video"
cat /etc/group | grep video
