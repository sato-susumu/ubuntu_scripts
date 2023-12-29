#!/bin/bash

sudo apt update
sudo apt install -y terminator

# camera
sudo apt install -y v4l-utils cheese
sudo usermod -a -G video $USER

