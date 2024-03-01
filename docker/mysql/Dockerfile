FROM mysql:8.0

ADD my.cnf /etc/mysql/conf.d/my.cnf
ADD exporter-setup.sh /docker-entrypoint-initdb.d/
RUN chmod +x /docker-entrypoint-initdb.d/exporter-setup.sh

CMD ["mysqld"]

EXPOSE 3306