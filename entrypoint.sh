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
	# Gather all PIDs except for pid 1 (entrypoint script) into a
	# space separated list, send SIGTERM and wait for those process to finish properly
	# ignore the process if it is a bash shell
	ps -e > /tmp/ps
	local PIDS=`grep -v -E "PID|\s1\s|ps" /tmp/ps | awk 'BEGIN { ORS=" " }; {print $1}'`;

	if [ -n "$PIDS" ]; then
		kill -TERM $PIDS
		for PID in $PIDS; do
			processName= $(cat /proc/"$PID"/cmdline)
			echo "> Waiting for process $PID ($processName) to finish.." 
			if [[ "$processName" == "bash" ]]; then
				echo "> Skipping bash shell process.."
				continue
			fi 
			while [[ -d /proc/$PID ]]; do
				sleep 0.1
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
