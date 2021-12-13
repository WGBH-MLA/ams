puts <<-ABOUT

This is a script to output the time it took for a bulkrax importer to run.

ABOUT
require 'csv'
require 'active_support/duration'

# recreate the file every time the script is run
file = "#{Rails.root}/public/ams2_bulkrax_times.csv"
File.delete(file) if File.exist?(file)

Bulkrax::Importer.all.each do |importer|
  total_objects_imported = importer.entries.count
  # skip this importer if it failed
  next unless total_objects_imported > 0

  start_time = importer.created_at
  end_time = importer.entries.last&.updated_at
  duration_in_seconds = ActiveSupport::Duration.build(end_time - start_time).to_i

  report = CSV.read(file, :headers => true) if File.exists?(file)
  if ARGV[0] && ARGV[0].include?('--generate')
    headers = ["Importer ID", "Importer Type", "Total Objects Imported", "Duration in seconds", "Date"]

    CSV.open(file, 'a+') do |row|
      row << headers unless report.present?
      row << [importer.id, importer.parser_klass, total_objects_imported, duration_in_seconds, importer.created_at]
    end
  end

  puts <<-RESULTS

  Importer ID: #{importer.id}
  Importer Type: #{importer.parser_klass}
  Total Objects Imported: #{total_objects_imported}

  Start time: #{start_time}
  End time:   #{end_time}

  Batch duration in seconds: #{duration_in_seconds.inspect}
  *****************
  RESULTS
end
