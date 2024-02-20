FROM grafana/grafana:8.3.0

ADD datasource.yml /etc/grafana/provisioning/datasources/

ADD dashboard.yml /etc/grafana/provisioning/dashboards/
ADD dashboards/dashboard-nginx.json /etc/grafana/provisioning/dashboards/
ADD dashboards/dashboard-varnish.json /etc/grafana/provisioning/dashboards/
ADD dashboards/dashboard-elastic.json /etc/grafana/provisioning/dashboards/
ADD dashboards/dashboard-redis.json /etc/grafana/provisioning/dashboards/
ADD dashboards/dashboard-php-fpm.json /etc/grafana/provisioning/dashboards/
ADD dashboards/dashboard-mysql.json /etc/grafana/provisioning/dashboards/

EXPOSE 3000
