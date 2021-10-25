ARG ROS_VERSION=melodic

FROM ros:${ROS_VERSION}
# original ARG is outside of this build stage
ARG ROS_VERSION
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get install -y firefox \
    openssh-server \
    xauth \
    ros-${ROS_VERSION}-desktop \
    python-catkin-tools \
    ros-${ROS_VERSION}-navigation \
    ros-${ROS_VERSION}-gmapping \
    ros-${ROS_VERSION}-robot-state-publisher \
    ros-${ROS_VERSION}-gazebo-ros-pkgs \
    ros-${ROS_VERSION}-teleop-twist-keyboard \
    ros-${ROS_VERSION}-tf \
    ros-${ROS_VERSION}-xacro \
    ros-${ROS_VERSION}-diagnostic-updater \
    ros-${ROS_VERSION}-ddynamic-reconfigure \
    && mkdir /var/run/sshd \
    && mkdir /root/.ssh \
    && chmod 700 /root/.ssh \
    && ssh-keygen -A \
    && sed -i "s/^.*PasswordAuthentication.*$/PasswordAuthentication no/" /etc/ssh/sshd_config \
    && sed -i "s/^.*X11Forwarding.*$/X11Forwarding yes/" /etc/ssh/sshd_config \
    && sed -i "s/^.*X11UseLocalhost.*$/X11UseLocalhost no/" /etc/ssh/sshd_config \
    && grep "^X11UseLocalhost" /etc/ssh/sshd_config || echo "X11UseLocalhost no" >> /etc/ssh/sshd_config \
    && rm -rf /var/lib/apt/lists/*

RUN apt-get update && apt-get install -y \
    ros-${ROS_VERSION}-rosbridge-suite \
    && rm -rf /var/lib/apt/lists/*

# create workspace and copy ROS packages
RUN mkdir -p /ros-navigation-local/src
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
RUN sed --in-place --expression \
    '$isource "/ros-navigation-local/devel/setup.bash"' \
    /ros_entrypoint.sh

ARG REMOTE_KEY
RUN echo "$REMOTE_KEY" >> /root/.ssh/authorized_keys

EXPOSE 22

RUN touch tmp.log
SHELL ["/bin/bash", "-c", "source /opt/ros/${ROS_VERSION}/setup.bash"]

ENTRYPOINT ["/bin/bash", "-c", "env | grep _ >> /etc/environment && /usr/sbin/sshd -p 2222 && sleep infinity"]