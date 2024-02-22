# Docker-infra-challenge

This project sets up a scalable Docker Compose infrastructure for running a Magento 2.4 instance, featuring MySQL, PHP-FPM, NGINX, Varnish Cache, Redis, Elasticsearch, RabbitMQ, Prometheus, Alert Manager, and Grafana. It focuses on performance monitoring and persistent data, with configured alerts for system health. You can see more details about the requirements for this challenge in the **docker-infra-challenge.txt** file.

## Quick Start

1. Environment Setup
2. Elasticsearch Optimizacion
3. Domain Mapping
4. Building Magento
5. Mysql Exporter user
6. Slack notifications

##  ===== 1. Environment Setup

 Update **env.dist** with your credentials, make sure to set the **mysql,grafana,rabbitmq,magento and mysql exporter** credentials after continue.
 
Complete the **composer.env.sample** too, add your keys from [this link.](https://commercemarketplace.adobe.com/customer/accessKeys/ "this link.")

```shell
COMPOSER_MAGENTO_USERNAME=your-public-key
COMPOSER_MAGENTO_PASSWORD=your-private-key
```

Now run the script **setup-env.sh** in the root directory, this script creates our .env and composer.env files from the templates, generates the SSL certificates for nginx (and if you already have certificates, you have the option to remplace it with new ones), update the UID and GID in the dockerfiles to match with the host user and create the magento folder.

```shell
sh setup-env.sh
```

##  ===== 2. ElasticSearch Optimization

```shell
sudo sysctl -w vm.max_map_count=262144
```
This command boosts elasticsearch performance by allowing more memory-mapped files, crucial for handling large 	datasets efficiently. I recommend you to execute this command before continue.

## ===== 3. Domain Mapping
 
 Add the domain docker.infra.challenge(or the domain of your choise) to your hosts file.

```shell
127.0.0.1   docker.infra.challenge
```
So you can access via [https://docker.infra.challenge/](https://docker.infra.challenge/ "https://docker.infra.challenge/")

##  ===== 4. Building Magento

Run docker compose up -d to launch all services in detached mode.
```shell
docker compose up -d
```

Before accessing the Magento container, ensure to give the necessary permissions on the folder .composer by running the following command:

```shell
sudo chown -R 1000:1000 ./docker/volume/.composer
```

Enter the Magento container as magento user with:

```shell
docker compose -f docker-compose.yml exec --user=magento magento bash 
```

Inside the container, initiate a Magento project using:

```shell
composer create-project --repository-url=https://repo.magento.com/ magento/project-community-edition .
```
And now run the provided scripts to build and install Magento, completing the setup process:

```shell
magento-build && magento-install
```

## ===== 5. Set Mysql Exporter user

Enter the MySQL container using this Docker command:

   ```shell
	docker exec -it mysql /bin/bash 
```

Use the MySQL client command to log in as the root user: 
   ```shell
	mysql -u root -p
```
Create a new user dedicated to monitoring. Set a password (as specified in your env.dist file):

   ```shell
 CREATE USER 'exporter'@'%' IDENTIFIED BY 'your-password-in-env.dist' WITH MAX_USER_CONNECTIONS 3;
```
   ```shell
 GRANT PROCESS, REPLICATION CLIENT, SELECT ON *.* TO 'exporter'@'%';
```
**  NOTE: It is recommended to set a max connection limit for the user to avoid overloading the server with monitoring scrapes under heavy load.**

we gonna reset both containers for this changes takes effects:
   ```shell
docker compose restart mysql mysql_exporter
```
With these steps completed, our Magento infrastructure is now up and running with monitoring capabilities.You can access Grafana to view the dashboards by navigating to https://docker.infra.challenge:3000(or to another domain specified in your env.dist file).

## ===== 6. Slack notifications

To set the slack notifications you need a Slack Workspace. You can quickly create one [here.](https://slack.com/create "here.")


Now go to your workspace and click in your **workspace name in the top left corner -> Tool and setting -> Manage apps.**

In the Manage apps directory, search for Incoming WebHooks and add it to your Slack workspace

Next, specify in which channel you like to receive notifications from Alertmanager(In our case we set the channel '#alerts' in the alertmanager.yml) After you confirm and add Incoming WebHooks integration, webhook URL (which is your Slack API URL) is displayed. Copy it.

Now you need to paste your slack api url in the alertmanager.yml file located in /docker/alertmanager/alertmanager.yml:

   ```shell
global:
  resolve_timeout: 1m
  slack_api_url: 'https://hooks.slack.com/services/rest/of/your/url' #change this url
```

and restart the Alertmanager service:
   ```shell
docker compose build alertmanager
```

   ```shell
docker compose up -d --force-recreate alertmanager
```


You can also set up alertmanager.yml to send the alerts trought Gmail with this configuration

  ```shell
global:
  resolve_timeout: 1m

route:
  receiver: 'gmail-notifications'

receivers:
- name: 'gmail-notifications'
  email_configs:
  - to: monitoringinstances@gmail.com
    from: monitoringinstances@gmail.com
    smarthost: smtp.gmail.com:587
    auth_username: monitoringinstances@gmail.com
    auth_identity: monitoringinstances@gmail.com
    auth_password: password
    send_resolved: true
```

For more information about the integrations of the alerts you can visit this [link.](https://grafana.com/blog/2020/02/25/step-by-step-guide-to-setting-up-prometheus-alertmanager-with-slack-pagerduty-and-gmail/ "link.")