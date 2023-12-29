#!/bin/bash

echo "lsusb | grep -iE 'pad|joy'"
lsusb | grep -iE 'pad|joy'

echo ""
echo "ls -l /dev/input/js*"
ls -l /dev/input/js*

echo ""
echo "jstest /dev/input/js0"
jstest /dev/input/js0

