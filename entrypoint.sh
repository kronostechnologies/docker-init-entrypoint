#!/usr/bin/env bash

execute_script() {
	local script=$1

	chmod +x "${script}"
	echo "> ${script}... processing"
	$script
}

process_scripts() {
	local path=$1

	for script in $(ls $path | sort -n); do
		execute_script "${path}/${script}"
	done
}

finish() {
	echo '> Stopping all services..'
	process_scripts /k/stop.d
	echo '> Shutting down now.'
}

trap finish SIGTERM SIGQUIT SIGINT

echo '> Starting all services..'
process_scripts /k/start.d
echo '> Fully Booted.'

if [[ -n "${@}" ]]; then
	echo "> Executing \`${@}\`"
	$@ &
	wait $!
else
	sleep infinity
fi
