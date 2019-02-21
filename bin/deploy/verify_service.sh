#!/bin/bash
source /etc/profile
sidekiq_pid_file=/var/www/ams/tmp/pids/sidekiq-ams.pid
process_id=-1
sidekiq_status=false

result=$(curl -s -o /dev/null -I -w "%{http_code}" $PRODUCTION_HOST)

if [ -f $sidekiq_pid_file ]; then
    process_id=`cat $sidekiq_pid_file`
fi

if [[ result -eq 200 ]] && ([ -f $sidekiq_pid_file ] &&  [ -e /proc/$process_id ])
then
    echo "All Good."
    exit 0
else


    if [[ result -ne 200 ]];then
        output="Apache ERROR Logs\n\n$(tail -n 20 /var/log/httpd/error_log)\n\n\n"
    fi

    if [ ! -f $sidekiq_pid_file ] ||  [ ! -e /proc/$process_id ]
    then
        output+="Production Sidekiq Logs\n\n$(tail -n 20 /var/www/ams/log/sidekiq.log)\n\n\n"
    fi


    output+="Production Rails Logs\n\n$(tail -n 20 /var/www/ams/log/production.log)\n\n\n"

    echo -e $output
    exit 1
fi
