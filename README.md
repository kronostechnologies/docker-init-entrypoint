# Docker Init Entrypoint

The script `entrypoint.sh` is a basic service init framework for containers. Entrypoint will source scripts in `/k/start.d` and `/k/stop.d` to start and stop services respectively.

The `CMD` directive of the dockerfile is an arbritrary command that will be executed in background. Entrypoint will wait on that process before shutting down.

## Install

Use the `ADD` and `ENTRYPOINT` directive e.g.:

```
FROM debian:latest
ADD https://github.com/kronostechnologies/docker-init-entrypoint/releases/download/1.0.0/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
```

## Flow
Entrypoint follows a specific flow divided in two main part: starting/waiting on services(1,2) and stopping/killing services (3,4).

  1. Source all the script in `/k/start.d/` folder sorted according to string numerical value.
  2. Execute and wait on the commands passed as parameter (`$@`) or, if no command are passed, sleep infinity. In docker, `$@` correspond to the `CMD` directive.
  3. Whenever `SIGTERM`, `SIGQUIT` or `SIGINT` is trapped, source all the script in `/k/stop.d`  folder sorted according to string numerical value.
  4. Send `SIGTERM` signal to any remaining process, excluding PID 1.

## Environment variable
### ENTRYPOINT_ROOT
If this variable is set, it will change the root directory of the start/stop scripts e.g.:
  - `ENTRYPOINT_ROOT=""` scripts will be sourced from `/start.d` and `/stop.d`
  - `ENTRYPOINT_ROOT="/root"` scripts will be sourced from `/root/start.d` and `/root/stop.d`.

Default is `/k`.

## Bootstraping Folders

The bootstraping folders are `/k/start.d/` and `/k/stop.d` which contains scripts to start and stop services respectively.

Here are some general advice about those scripts :

- Scripts must not be blocking (hanging).
- Scripts' name should start with three (3) digits `100_apache2.sh`.

The `CMD` directive of the dockerfile is an arbritrary command that will be executed in background. The entrypoint will wait on that process before shutting down. Generally, `CMD` would be a command that would agregate logs to stdout such as `tail`. You can also use a custom script.

  > Note: you cannot set `CMD` to an interactive command. For exemple, setting `/bin/bash` as `CMD` will start a shell in the background and won't be accessible.

## Examples

Examples can be found in the `examples` directory of this repository.

## Troubleshoot
### Error `/usr/local/bin/entrypoint.sh: line 15: ps: command not found`
Some base image such as debian "-slim" variant does not come with `ps` installed. Entrypoint needs `ps` to list remaining process so it can terminate them. Install ps with `apt-get update && apt-get install procps -y` in your image.
