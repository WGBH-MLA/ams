#!/bin/bash
cd /var/www/ams
bundle install
rails db:migrate
chown -R ec2-user:ec2-user /var/www/ams
if [ -n $SECRET_KEY_BASE ]; then
echo "export SECRET_KEY_BASE=`rails secret`" >> /etc/profile
source /etc/profile
fi
service httpd restart
