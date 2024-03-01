# Docker-infra-challenge

This project sets up a scalable Docker Compose infrastructure for running a Magento 2.4 instance, featuring MySQL, PHP-FPM, NGINX, Varnish Cache, Redis, Elasticsearch, RabbitMQ, Prometheus, Alert Manager, and Grafana. It focuses on performance monitoring and persistent data, with configured alerts for system health. You can see more details about the requirements for this challenge in the **docker-infra-challenge.txt** file.

## Quick Start

1. Environment Setup
2. Elasticsearch Optimizacion
3. Domain Mapping
4. Run infra

##  ===== 1. Environment Setup

 Update **env.dist** with your credentials, make sure to set the **mysql,grafana,rabbitmq,magento and mysql exporter** credentials after continue.


You can also add your Slack API URL in the **env.dist** to integrate Slack to receive alerts in the desired channel.
To set the slack notifications you need a Slack Workspace. You can quickly create one [here.](https://slack.com/create "here.")

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

##  ===== 4. Run infra

First, initiate the RabbitMQ container:

```shell
docker compose up -d rabbit
```

Make sure RabbitMQ is operational and your user is created before proceeding

Ensure to give the necessary permissions on the folder .composer by running the following command:

```shell
sudo chown -R 1000:1000 ./docker/volume/.composer
```

Now just run docker compose up -d to launch all the other services in detached mode:

```shell
docker compose up -d
```
