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
  elapsed_time_in_seconds = 0

  importer.entries.each do |entry|
    start_time = importer.created_at
    end_time = entry.updated_at

    duration_in_seconds = ActiveSupport::Duration.build(end_time - start_time).to_i
    elapsed_time_in_seconds += duration_in_seconds
  end

  report = CSV.read(file, :headers => true) if File.exists?(file)

  if ARGV[0] && ARGV[0].include?('--generate')
    headers = ["Importer ID", "Importer Type", "Total Objects Imported", "Elasped Time in seconds", "Date"]

    CSV.open(file, 'a+') do |row|
      row << headers unless report.present?
      row << [importer.id, importer.parser_klass, total_objects_imported, elapsed_time_in_seconds, importer.created_at]
    end
  end

  puts <<-RESULTS

  Importer ID: #{importer.id}
  Importer Type: #{importer.parser_klass}
  Total Objects Imported: #{total_objects_imported}

  Start time: #{importer.created_at}
  End time:   #{importer.entries.last&.updated_at}

  Batch duration in seconds: #{elapsed_time_in_seconds.inspect}
  *****************
  RESULTS
end
