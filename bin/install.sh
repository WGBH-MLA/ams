#!/bin/bash
source /home/ec2-user/.bash_profile
cd /var/www/ams
bundle install
rails db:migrate
chown -R ec2-user:ec2-user /var/www/ams
service httpd restart