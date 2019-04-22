puts <<-ABOUT

This is a highly specific script to output the time it took for a batch to run.

This is only a stop-gap until we implement some better tracking of these things in the UI.

It assumes many things:
1) The rails log file is at log/production.log (relative to cwd).
2) The last POST request to /batches in log/production.log indicates the beginning of the most recently run batch.
3) The Sidekiq log is in log/sidekiq.log.
4) All sidekiq processes are logging to the same file at log/sidekiq.loq.
5) The last logged line in log/sidekiq.log represents the last job ran in the most recent batch.
6) Both logs include a timestamp in the form 2019-04-09T01:34:56.345677 or 2019-04-09T01:34:56.345Z

Assuming all these things, here's what we found...
ABOUT

timestamp_regex = /\d\d\d\d\-\d\d\-\d\dT\d\d\:\d\d\:\d\d\.\d+Z?/

rails_log_file_path = "log/production.log"
sidekiq_log_path = 'log/sidekiq.log'

batch_submitted_log_line = `grep 'POST "/batches' #{rails_log_file_path} | tail -n 1`
last_job_log_line = `grep -a "INFO: done:" #{sidekiq_log_path} | tail -n 1`

extracted_start_time = batch_submitted_log_line.match(timestamp_regex)[0]
extracted_end_time = last_job_log_line.match(timestamp_regex)[0]

require 'active_support/duration'
duration = ActiveSupport::Duration.build(Time.parse(extracted_end_time) - Time.parse(extracted_start_time))

puts <<-RESULTS

Log indicating batch start from #{rails_log_file_path}...

  #{batch_submitted_log_line}

Log indicating batch end from #{sidekiq_log_path}...

  #{last_job_log_line}

Start time: #{extracted_start_time}
End time:   #{extracted_end_time}

Batch duration: #{duration.inspect}

RESULTS
