#!/bin/bash
cd /var/www/ams
bundle install
rails db:migrate
service httpd restart