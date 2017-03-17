#!/usr/bin/env bash

process_scripts() {
	local path=$1

	for script in $(ls $path | sort -n); do
		echo "> ${path}/${script}... processing"
		source "${path}/${script}"
	done
}

finish() {
	echo '> Stopping all services..'
	process_scripts "${ENTRYPOINT_ROOT}/stop.d"
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
