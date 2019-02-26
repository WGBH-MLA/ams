#!/bin/bash
/bin/bash --login
sudo yum -y update
source /etc/profile
echo "Running Deployment for ID: $DEPLOYMENT_ID"
export APP_HOME=/var/www/ams
sudo chown -R ec2-user:ec2-user $APP_HOME
cd $APP_HOME
bundle install --deployment --without development test
echo "ruby version:`ruby -v`"
echo "rails versions:`bundle exec rails -v`"
echo "node version:`node -v`"
echo "yarn version:`yarn -v`"
bundle exec rails db:migrate
bundle exec rails assets:precompile
if [ -z $SECRET_KEY_BASE ]; then
sudo echo "export SECRET_KEY_BASE=`bundle exec rails secret`" >> /etc/profile
source /etc/profile
fi
DEPLOYMENT_ID=$DEPLOYMENT_ID ruby bin/deploy/create_deployment_details_page.rb
sudo service httpd restart
sleep 2
sudo service sidekiq restart
sleep 2
