ARG ROS_VERSION=melodic

FROM ros:${ROS_VERSION}
# original ARG is outside of this build stage
ARG ROS_VERSION
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get install -y \
    software-properties-common

RUN apt-get update \
    && apt-get install -y \
    python3-catkin-tools \
    ros-${ROS_VERSION}-navigation \
    ros-${ROS_VERSION}-gmapping \
    ros-${ROS_VERSION}-robot-state-publisher \
    ros-${ROS_VERSION}-gazebo-ros-pkgs \
    ros-${ROS_VERSION}-teleop-twist-keyboard \
    ros-${ROS_VERSION}-tf \
    ros-${ROS_VERSION}-xacro \
    ros-${ROS_VERSION}-diagnostic-updater \
    ros-${ROS_VERSION}-ddynamic-reconfigure \
    && rm -rf /var/lib/apt/lists/*

RUN apt-get update && apt-get install -y \
    libeigen3-dev \
    && rm -rf /var/lib/apt/lists/*

# create workspace
RUN mkdir -p /ros-navigation-local/src

# copy ROS packages
COPY  kobuki_description /ros-navigation-local/src/kobuki_description
COPY  turtlebot_bringup /ros-navigation-local/src/turtlebot_bringup
COPY  turtlebot_create /ros-navigation-local/src/turtlebot_create
COPY  turtlebot_description /ros-navigation-local/src/turtlebot_description
COPY  turtlebot_navigation /ros-navigation-local/src/turtlebot_navigation
COPY  turtlebot_navigation_gazebo /ros-navigation-local/src/turtlebot_navigation_gazebo
COPY  turtlebot_rviz_launchers /ros-navigation-local/src/turtlebot_rviz_launchers
COPY  turtlebot_teleop /ros-navigation-local/src/turtlebot_teleop

WORKDIR /ros-navigation-local

# compile packages
RUN catkin config --extend /opt/ros/${ROS_VERSION} && \
    catkin build

# RUN sed --in-place --expression \
#     '$isource "/ros-navigation-local/devel/setup.bash"' \
    # /ros_entrypoint.sh