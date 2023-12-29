#!/bin/bash

# Line to be added
lineToAdd="bind 'set bell-style none'"

# Check if the specified line exists in the file
if ! grep -Fxq "$lineToAdd" ~/.bashrc; then
    # If it doesn't exist, add the line
    echo "$lineToAdd" >> ~/.bashrc
    echo "Bell sound setting has been disabled."
else
    echo "Bell sound setting is already disabled."
fi
