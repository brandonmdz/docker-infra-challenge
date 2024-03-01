FROM prom/alertmanager:v0.22.0

COPY alertmanager.yml.sample /etc/alertmanager/
COPY --chmod=755 docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]

CMD ["alertmanager"]