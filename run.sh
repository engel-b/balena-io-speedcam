#!/bin/bash

# Start the first process
/root/speed-camera/speed-cam.sh start > /dev/null
status=$?
if [ $status -ne 0 ]; then
  echo "Failed to start speed-cam: $status"
  exit $status
fi

# Start the second process
/root/speed-camera/webserver.sh start > /dev/null
status=$?
if [ $status -ne 0 ]; then
  echo "Failed to start webserver: $status"
  exit $status
fi

# Naive check runs checks once a minute to see if either of the processes exited.
# This illustrates part of the heavy lifting you need to do if you want to run
# more than one service in a container. The container exits with an error
# if it detects that either of the processes has exited.
# Otherwise it loops forever, waking up every 60 seconds

while sleep 60; do
  exitAll=0
  ps aux |grep speed-cam |grep -q -v grep
  PROCESS_1_STATUS=$?
  ps aux |grep webserver |grep -q -v grep
  PROCESS_2_STATUS=$?
  # If the greps above find anything, they exit with 0 status
  # If they are not both 0, then something is wrong
  if [ $PROCESS_1_STATUS -ne 0 ]; then
    echo "speed-cam.sh already exited."
    exitAll=1
  fi
  if [ $PROCESS_2_STATUS -ne 0 ]; then
    echo "webserver.sh already exited."
    exitAll=1
  fi
  if [ $exitAll -ne 0 ]; then
    echo "One of the processes has already exited."
    exit 1
  fi
done
