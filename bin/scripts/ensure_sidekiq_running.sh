#!/bin/bash -l
#
# Script make sure there are N Sidekiq processes running.
#
# This script was written to be run from cron. Here's the crontab we're using...
#  * * * * * cd [PATH_TO_PROJECT_ROOT] && bin/scripts/ensure_sidekiq_running.sh 2>&1 >> log/sidekiq.log
#
# NOTE: The -l option in the shebang above means we run the script as if it
# were a login shell, meaning it loads the user environment. When using RVM
# this is important for making sure the correct ruby version is selected, and
# gems are available in $PATH (e.g. `bundler').
#
# NOTE: This script expects to be run from the project root, i.e. where relative
# paths to config/sidekiq.yml and log/sidekiq.log are legit, and where
# `bundle exec sidekiq' will work.
#
# NOTE: When cron jobs fail, the failures are mailed to you. So check your email
# or files at /var/spool/mail/[user] or /var/mail/[user]
#
# Variables. These may change depending on your environment.
num_processes=1
num_threads=1
environment=${RAILS_ENV:-'development'}

# Get the number of currently running Sidekiq processes.
currently_running=`ps aux | egrep 'sidekiq.*\[[0-9]+ of [0-9]+ busy\]' | wc -l | awk '{ print $1 }'`
echo "Ensuring $num_processes Sidekiq process(es): found $currently_running running."

# If not enough processes are running...
if [ $currently_running -lt $num_processes ]
then
  # Calculate how many more processes we want to be running.
  diff=$(($num_processes-$currently_running))
  for ((i=1; i<=$diff; i++)); do
    echo "Starting Sidekiq process #$i...."
    echo "bundle exec sidekiq -e $environment -C config/sidekiq.yml -c $num_threads 2>&1 >> log/sidekiq.log &"
    # Start sidekiq, append it's output to log/sidekiq.log, and run in the background.
    bundle exec sidekiq -e $environment -C config/sidekiq.yml -c $num_threads 2>&1 >> log/sidekiq.log &
  done
fi
