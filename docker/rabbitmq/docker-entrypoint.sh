#!/bin/sh

rabbitmq-plugins enable rabbitmq_management
rabbitmqctl enable_feature_flag classic_mirrored_queue_version

rabbitmq-server -detached

sleep 10

rabbitmqctl add_user $RABBITMQ_USER $RABBITMQ_PASSWORD
rabbitmqctl set_user_tags $RABBITMQ_USER administrator
rabbitmqctl set_permissions -p / $RABBITMQ_USER ".*" ".*" ".*"
echo "*** User '$RABBITMQ_USER' with password '$RABBITMQ_PASSWORD' completed. ***"
echo "*** Log in the WebUI at port 15672 (example: http://localhost:15672) ***"

rabbitmqctl stop
exec rabbitmq-server $@