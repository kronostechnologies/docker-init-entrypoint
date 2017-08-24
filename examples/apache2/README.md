# Examples

Below a simple docker file project for apache2.

## File tree
```
14:31:33 nvanheuverzwijn ~/Projects/test tree
.
├── 100-start-apache2.sh (0755)
├── 100-stop-apache2.sh  (0755)
└── dockerfile           (0644)
```

  > Notice the +x mod on shell script

### 100-start-apache2.sh
```
#!/bin/bash

service apache2 start
```

### 100-stop-apache2.sh
```
#!/bin/bash

service apache2 stop
```

### entrypoint.sh
See the file `entrypoint.sh` in this repository

#### dockerfile
```
FROM debian:latest

RUN apt-get update && apt-get install -y -q apache2 && apt-get clean

ADD https://raw.githubusercontent.com/kronostechnologies/docker-init-entrypoint/master/entrypoint.sh /usr/local/bin/entrypoint.sh

COPY ./100-start-apache2.sh /k/start.d/100-apache2.sh
COPY ./100-stop-apache2.sh /k/stop.d/100-apache2.sh

EXPOSE 80

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["tail", "-F", "/var/log/apache2/access.log", "/var/log/apache2/error.log"]
```

## Starting this docker

```
$ docker run --rm --name test apache2
> Starting all services..
> /k/start.d/100-apache2.sh... processing
Starting web server: apache2AH00558: apache2: Could not reliably determine the server's fully qualified domain name, using 172.17.0.2. Set the 'ServerName' directive globally to suppress this message
.
> Fully Booted.
> Executing `tail -F /var/log/apache2/access.log /var/log/apache2/error.log`
==> /var/log/apache2/access.log <==

==> /var/log/apache2/error.log <==
[Mon Mar 06 19:35:44.938598 2017] [mpm_event:notice] [pid 35:tid 140286129534848] AH00489: Apache/2.4.10 (Debian) configured -- resuming normal operations
[Mon Mar 06 19:35:44.938686 2017] [core:notice] [pid 35:tid 140286129534848] AH00094: Command line: '/usr/sbin/apache2'
```
  > The docker is now waiting on the `tail` command.

### Stopping this docker

```
> Stopping all services..
> /k/stop.d/100-apache2.sh... processing
Stopping web server: apache2[Mon Mar 06 19:36:16.956781 2017] [mpm_event:notice] [pid 35:tid 140286129534848] AH00491: caught SIGTERM, shutting down
.
> Shutting down now.
```
