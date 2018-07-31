#!/bin/bash
/bin/bash --login
source /etc/profile
echo "Running Deployment for ID: $DEPLOYMENT_ID"
sudo yum -y update
export HOME=/var/www/ams
cd $HOME
rvm gemset use ams --create
bundle install
echo "ruby version:`ruby -v`"
echo "rails versions:`rails -v`"
echo "node version:`node -v`"
echo "yarn version:`yarn -v`"
rails db:migrate
rails assets:precompile
sudo chown -R ec2-user:ec2-user /var/www/ams
if [ -z $SECRET_KEY_BASE ]; then
sudo echo "export SECRET_KEY_BASE=`rails secret`" >> /etc/profile
source /etc/profile
fi
DEPLOYMENT_ID=$DEPLOYMENT_ID ruby bin/deploy/create_deployment_details_page.rb
sudo service httpd restart
touch tmp/restart.txt
