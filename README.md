# Launch RQT GUI running in ROS development container

```
ssh -X -p 2222 root@localhost "source /ros-navigation-local/devel/setup.bash && gazebo"
```

## Run tutorial

```
roslaunch turtlebot_navigation_gazebo main.launch
roslaunch turtlebot_teleop keyboard_teleop.launch
roslaunch turtlebot_navigation_gazebo gmapping_demo.launch
roslaunch turtlebot_rviz_launchers view_mapping.launch
```
