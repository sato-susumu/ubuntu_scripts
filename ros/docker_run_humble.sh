#!/bin/bash

#!/bin/bash

# Default command (will be executed if no arguments are provided)
DEFAULT_CMD="/bin/bash"

# Check if there are any arguments
if [ $# -eq 0 ]; then
    # If no arguments are provided, execute the default command
    CMD="$DEFAULT_CMD"
else
    # If arguments are provided, execute the specified command
    CMD="$@"
fi

# Run the Docker container
docker run -it --rm --name humble \
    -e DISPLAY \
    -e QT_X11_NO_MITSHM=1 \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    --net=host \
    --privileged \
    osrf/ros:humble \
    $CMD

