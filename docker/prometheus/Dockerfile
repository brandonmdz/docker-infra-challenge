FROM prom/prometheus:v2.30.0

ADD prometheus.yml /etc/prometheus/prometheus.yml
ADD rules.yml /etc/prometheus/rules.yml
ADD alerts.yml /etc/prometheus/alerts.yml

EXPOSE 9090
