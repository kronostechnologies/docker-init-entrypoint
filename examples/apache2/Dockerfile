FROM debian:latest

RUN apt-get update && apt-get install -y -q apache2 && apt-get clean

ADD https://github.com/kronostechnologies/docker-init-entrypoint/releases/download/1.0.0/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

COPY ./100-start-apache2.sh /k/start.d/100-apache2.sh
COPY ./100-stop-apache2.sh /k/stop.d/100-apache2.sh

EXPOSE 80

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["tail", "-F", "/var/log/apache2/access.log", "/var/log/apache2/error.log"]
