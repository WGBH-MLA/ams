# lib/tasks/ams/copy_files_from_s3.rake

# AWS_ACCESS_KEY_ID=
# AWS_SECRET_ACCESS_KEY=
# AWS_S3_BUCKET=
# AWS_REGION=
# S3_FOLDER=

# rake ams:copy_files_from_s3

namespace :ams do
  desc 'Copy XML files from S3 and import using Bulkrax'

  task copy_files_from_s3: :environment do
    require 'aws-sdk-s3'
    require 'fileutils'
    require 'logger'

    # Ensure AWS environment variables and S3 folder are set
    unless ENV['AWS_ACCESS_KEY_ID'] && ENV['AWS_SECRET_ACCESS_KEY'] && ENV['AWS_S3_BUCKET'] && ENV['AWS_REGION'] && ENV['S3_FOLDER']
      raise 'Missing AWS credentials, bucket/region information, or S3 folder. Please set AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, AWS_S3_BUCKET, AWS_REGION, and S3_FOLDER.'
    end

    # AWS S3 bucket setup
    bucket = Aws::S3::Resource.new(region: ENV.fetch('AWS_REGION')).bucket(ENV.fetch('AWS_S3_BUCKET'))

    # S3 folder from ENV
    s3_folder = ENV.fetch('S3_FOLDER')

    # Ensure necessary directories are created
    FileUtils.mkdir_p('tmp/imports')

    # Log file to store file list
    full_list_log_path = 'tmp/imports/full_list.log'

    # Create or overwrite `full_list.log` by listing files from S3
    File.open(full_list_log_path, 'w') do |log_file|
      bucket.objects(prefix: "#{s3_folder}/").each do |obj|
        file_name = obj.key.sub("#{s3_folder}/", "") # Remove folder prefix from file name

        # Skip folder names and only log actual files
        next if file_name.end_with?('/') || file_name.empty?

        log_file.puts file_name
      end
    end

    # Display the generated full_list.log
    puts "Generated full_list.log successfully with the following files:"
    puts File.read(full_list_log_path)

    # Set larger batch parameters
    batch_size = 100000  # Adjust the size based on the number of files you want to process
    batch_placeholder = 1  # Set this to the appropriate starting point

    start_at = batch_placeholder
    end_at = batch_placeholder + batch_size - 1

    batch_name = "AMS1Importer_#{start_at}-#{end_at}"
    file_path = "tmp/imports/#{batch_name}"
    FileUtils.mkdir_p(file_path)

    puts "Starting file download from S3 folder #{s3_folder} for batch: #{batch_name}"

    # Download files from S3 folder
    File.open(full_list_log_path) do |f|
      f.each.with_index do |row, i|

        row.strip!

        begin
          # Specify the folder in the S3 path
          obj = bucket.object("#{s3_folder}/#{row}")

          # Log the full path it's trying to download
          puts "Attempting to download: #{obj.key}"

          # Check if object exists before attempting download
          if obj.exists?
            download_path = File.join(file_path, File.basename(row))
            puts "Downloading file to: #{download_path}"

            obj.download_file(download_path)
            puts "#{i + 1} files downloaded: #{row}"
          else
            puts "File not found in S3: #{row}"
          end

        rescue Aws::S3::Errors::ServiceError => e
          puts "Error downloading file #{row}: #{e.message}"
        end
      end
    end

    puts "Finished downloading files. Starting Bulkrax import..."

    # Create a Bulkrax importer
    importer = Bulkrax::Importer.create(
      name: batch_name,
      admin_set_id: ENV.fetch('ADMIN_SET_ID', 'admin_set/default'),
      user_id: ENV.fetch('USER_ID', 1),
      frequency: 'PT0S',
      parser_klass: 'PbcoreXmlParser',
      parser_fields: {
        'record_element' => 'pbcoreDescriptionDocument',
        'import_type' => 'single',
        'visibility' => 'restricted',
        'rights_statement' => '',
        'override_rights_statement' => '0',
        'file_style' => 'Specify a Path on the Server',
        'import_file_path' => file_path,
        'replace_files' => true
      }
    )

    # Log information about the importer
    puts "Bulkrax importer created with ID: #{importer.id}, name: #{importer.name}"

    # Optionally move or rename files if necessary (file cleanup)
    Dir.glob("#{file_path}/*xml").each do |file|
      new_name = file.strip
      FileUtils.mv(file, new_name) if file != new_name
      puts "Renamed file: #{file} to #{new_name}"
    end

    puts "Files renamed successfully."

    # Log file keys for future use
    bucket.objects(prefix: s3_folder).each do |obj|
      puts "Processed file from S3: #{obj.key}"
    end

    puts "Task completed successfully!"
  end
end
