#!/bin/bash

# Get today's date in YYYY-MM-DD format
today=$(date +%Y-%m-%d)

# Delimiter string
delimiter="# Customizations below are added on or after $today"

# Check if the delimiter line is already in .bashrc
if ! grep -qx "$delimiter" ~/.bashrc; then
    # Add the delimiter line to .bashrc
    echo "" >> ~/.bashrc
    echo "$delimiter" >> ~/.bashrc
    echo "Delimiter line has been added to .bashrc."
else
    echo "Delimiter line is already in .bashrc."
fi
