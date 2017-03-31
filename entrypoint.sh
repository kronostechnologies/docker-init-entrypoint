#!/usr/bin/env bash

process_scripts() {
	local path=$1

	for script in $(ls $path | sort -n); do
		echo "> Sourcing '${path}/${script}'.."
		source "${path}/${script}"
	done
}

kill_remaining_process() {
	# Gather all PIDs except for pid 1 (entrypoint script) into a
	# space separated list, send SIGTERM and wait for those process to finish properly
	PIDS=`ps -e | grep -v --exclude=' ${BASHPID} ' -E "PID|\s1\s" | awk 'BEGIN { ORS=" " }; {print $1}'`
	kill -TERM $PIDS >> /tmp/pidtokill

	for PID in $PIDS; do
		while [[ -d /proc/$PID ]]; do
			sleep 0.1
		done
	done
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

if [[ -n "${@}" ]]; then
	echo "> Executing \`${@}\`"
	$@ &
	wait $!
else
	sleep infinity
fi
