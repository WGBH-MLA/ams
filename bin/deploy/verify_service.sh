#!/bin/bash -le
cd /var/www/ams
bin/rails verify_service:sidekiq
bin/rails verify_service:homepage
echo "End of verify_service.sh"
exit 0;
