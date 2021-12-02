#!/bin/bash
set -e

# setup ros environment
source "/opt/ros/$ROS_DISTRO/setup.bash"
source "/ros-navigation-local/devel/setup.bash"

exec "$@"