#!/usr/bin/env bash

process_scripts() {
  local path=$1

  if [[ ! -d $path ]]; then
    echo "> Entrypoint point path script '${path}' does not exist."
    echo "> Skipping.."
  else
    for script in $(ls $path | sort -n); do
      echo "> Sourcing '${path}/${script}'.."
      source "${path}/${script}"
    done
  fi
}

kill_remaining_process() {
  # Gather all PIDs except for pid 1 (entrypoint script) into a space separated list

  ps -e > /tmp/ps
  local APACHE_PIDS=$(grep -v -E "PID|\s1\s|ps" /tmp/ps | grep apache | awk 'BEGIN { ORS=" " }; {print $1}')
  local PIDS=$(grep -v -E "PID|\s1\s|ps" /tmp/ps | grep -v apache | awk 'BEGIN { ORS=" " }; {print $1}');
  rm /tmp/ps

  # For apache services, send a SIGWINCH to graceful-stop the process
  if [ -n "$APACHE_PIDS" ]; then
    kill -SIGWINCH $APACHE_PIDS
    for PID in $APACHE_PIDS; do
      while [[ -d /proc/$PID ]]; do
        sleep 0.2
      done
    done
  fi

  # For non-apache services, send a SIGTERM
  if [ -n "$PIDS" ]; then
    kill -TERM $PIDS
    for PID in $PIDS; do
      while [[ -d /proc/$PID ]]; do
        sleep 0.2
      done
    done
  fi
}

finish() {
  trap "" SIGTERM SIGQUIT SIGINT
  echo '> Stopping all services..'
  process_scripts "${ENTRYPOINT_ROOT}/stop.d"
  echo '> Killing remaining process..'
  kill_remaining_process
  echo '> Shutting down now.'
}

trap finish SIGTERM SIGQUIT SIGINT

if [ -z ${ENTRYPOINT_ROOT+x} ]; then
  ENTRYPOINT_ROOT="/k"
fi

echo '> Starting all services..'
process_scripts "${ENTRYPOINT_ROOT}/start.d"
echo '> Fully Booted.'

if [[ -n "${*}" ]]; then
  echo "> Executing \`${*}\`"
  /bin/bash -c "${*}" &
else
  sleep infinity &
fi
wait $!

finish
