#!/bin/bash
source /etc/profile
cd /var/www/ams
bundle install
rails db:migrate
rails assets:precompile
chown -R ec2-user:ec2-user /var/www/ams
if [ -z $SECRET_KEY_BASE ]; then
echo "export SECRET_KEY_BASE=`rails secret`" >> /etc/profile
source /etc/profile
fi
bin/deploy/create_deployment_details_page.rb
service httpd restart
