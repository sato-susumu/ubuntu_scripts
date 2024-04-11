#!/bin/bash

sudo cp /etc/gdm3/custom.conf /etc/gdm3/custom.conf.backup

sudo sed -i '/^\[daemon\]/a AutomaticLoginEnable=True' /etc/gdm3/custom.conf
sudo sed -i "/^\[daemon\]/a AutomaticLogin=$USER" /etc/gdm3/custom.conf
