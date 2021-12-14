puts <<-ABOUT

This is a script to output the time it took for a bulkrax importer to run.

ABOUT
require 'csv'
require 'active_support/duration'

# recreate the file every time the script is run
file = "#{Rails.root}/public/ams2_bulkrax_times.csv"
File.delete(file) if File.exist?(file)

total_objects_in_all_importers = 0
total_time_for_all_importers = 0

Bulkrax::Importer.all.each do |importer|
  total_objects_imported = importer.entries.count
  # skip this importer if it failed
  next unless total_objects_imported > 0

  start_time = importer.created_at
  end_time = importer.entries.last&.updated_at
  duration_in_seconds =  ActiveSupport::Duration.build(end_time - start_time)
                                                .to_i
                                                .to_f
                                                .round(2)

  total_objects_in_all_importers += total_objects_imported
  total_time_for_all_importers += duration_in_seconds

  report = CSV.read(file, :headers => true) if File.exists?(file)
  if ARGV[0] && ARGV[0].include?('--generate')
    headers = ["Importer ID", "Importer Type", "Total Objects Imported", "Duration in seconds", "Average", "Date"]

    CSV.open(file, 'a+') do |row|
      row << headers unless report.present?
      row << [importer.id, importer.parser_klass, total_objects_imported, duration_in_seconds, "1 object per #{(duration_in_seconds / total_objects_imported).round(2)} seconds", importer.created_at]
    end
  end
end

CSV.open(file, 'a+') do |row|
  row << []
  row << ["", "", total_objects_in_all_importers, total_time_for_all_importers, "1 object per #{(total_time_for_all_importers / total_objects_in_all_importers).round(2)} seconds", ""]
end

puts <<-RESULTS
Done! Please download the CSV for details per importer.

*****************

Total objects across all importers: #{total_objects_in_all_importers}
Total time to complete all importers: #{total_time_for_all_importers}
Average import time: 1 object per #{(total_time_for_all_importers / total_objects_in_all_importers).round(2)} seconds

RESULTS
