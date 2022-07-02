#!/bin/bash
#
# a2tm
#
# chkconfig:   - 88 88
# description: Script for start, stop and check status of a2tm
#
# processname: a2tm
#

# Function for start
function start_service() {
  echo "# Running at2m process"
  /usr/bin/a2tm start &
  echo "# Finished a2tm process"
}

# Function for stop
function stop_service() {
  echo "# Stopping the aria2c process"
  killall aria2c 2> /dev/null
  echo "# Stopping the a2tm process"
  killall a2tm 2> /dev/null
}

# Function for restart
function restart_service() {
  stop_service
  sleep 3
  start_service
}

# Function for check status
function status_service() {
  aria2c_p=$(ps -e | grep aria2c)
  if [ -z "${aria2c_p}" ] ; then
    echo "# The aria2c process is not running"
  else
    echo "# The aria2c process is running"
  fi
}

# Show help
function show_help() {
  echo "# Use: $0 {start|stop|restart|status}"
}

case ${1} in
  start)
    start_service
  ;;
  stop)
    stop_service
  ;;
  restart)
    restart_service
  ;;
  status)
    status_service
  ;;
  *)
    show_help
esac
