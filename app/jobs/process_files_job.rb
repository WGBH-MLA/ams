# app/jobs/process_files_job.rb
class ProcessFilesJob < ApplicationJob
  queue_as :default

  def perform(file_path)
    puts "file_path=#{file_path}"
    # Extract the directory where the file is located and the base name without .txt extension
    dir_path = File.dirname(file_path)
    puts "dir_path=#{dir_path}"
    base_name = File.basename(file_path, '.txt')
    puts "base_name=#{base_name}"

    # Create a new directory named after the base name of the file
    new_dir_path = File.join(dir_path, base_name)
    puts "new_dir_path=#{new_dir_path}"
    FileUtils.mkdir_p(new_dir_path) unless Dir.exist?(new_dir_path)

    # Process the file lines as before
    file_lines = File.readlines(file_path)

    file_lines.each do |line|
      filename = line.strip.sub(/^cpb-aacip-/, '') + '.xml'
      # Correctly execute the find command and capture its output
      puts "before find . -type f -name '#{filename}'"
      find_command = "find . -type f -name '#{filename}'"
      puts "after find . -type f -name '#{filename}'"
      found_files = `#{find_command}`.split("\n")

      # Adjust the destination_path to be the new directory
      destination_path = File.join("./tmp/imports", base_name)
      puts "destination_path=#{destination_path}"
      FileUtils.mkdir_p(destination_path) unless Dir.exist?(destination_path)

      found_files.each do |found_file_path|
        if File.exist?(found_file_path)
          FileUtils.mv(found_file_path, destination_path)
          puts "Moved #{found_file_path} (found_file_path) to #{destination_path} (destination_path)"
        end
      end
    end
  end
end
