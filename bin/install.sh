#!/bin/bash
cd /var/www/ams
bundle install
if [ -n $RAILS_SECRET_KEY ]; then
echo "export SECRET_KEY_BASE=`rails secret`" >> /etc/profile
source /etc/profile
fi
rails db:migrate
rails assets:precompile
chown -R ec2-user:ec2-user /var/www/ams
service httpd restart