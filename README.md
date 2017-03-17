# Docker Init Entrypoint

The script `entrypoint.sh` is a basic service init framework for containers. Entrypoint will source scripts in `/k/start.d` and `/k/stop.d` to start and stop services respectively. The `CMD` directive of the dockerfile is an arbritrary command that will be executed in background. The entrypoint will wait on that process before shutting down.

## Install

Simply use the `ADD` and `ENTRYPOINT` directive i.e.:

```
FROM debian:latest
ADD https://github.com/kronostechnologies/docker-init-entrypoint/releases/download/1.0.0/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
```
 
## Bootstraping Folders

The bootstraping folders are `/k/start.d/` and `/k/stop.d` which contains scripts to start and stop services respectively. 

Here are some general advice about those scripts :

- Scripts must not be blocking (hanging).
- Scripts' name should start with three (3) digits `100_apache2.sh`.

The `CMD` directive of the dockerfile is an arbritrary command that will be executed in background. The entrypoint will wait on that process before shutting down. Generally, `CMD` would be a command that would agregate logs to stdout such as `tail`. You can also use a custom script.

  > Note: you cannot set `CMD` to an interactive command. For exemple, setting `/bin/bash` as `CMD` will start a shell in the background and won't be accessible.

## Examples

Examples can be found in the `examples` directory of this repository.
