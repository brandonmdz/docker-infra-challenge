FROM varnish:7.0

RUN apt-get update && apt-get install -y \
        git \
        golang \
        procps \
        supervisor && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN git clone https://github.com/jonnenauha/prometheus_varnish_exporter.git /tmp/prometheus_varnish_exporter && \
    cd /tmp/prometheus_varnish_exporter && \
    go build -o /usr/local/bin/prometheus_varnish_exporter

COPY etc/varnish.vcl /etc/varnish/
COPY bin/docker-entrypoint.sh /docker-entrypoint.sh

RUN chmod +x /docker-entrypoint.sh

EXPOSE 6081 6082 9131

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]