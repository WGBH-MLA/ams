module ZipHelpers
  # Zips a given path to a temporary location, and returns the location.
  def zip_to_tmp(path)
    absolute_path = File.expand_path(path)
    basename = File.basename(absolute_path)
    parent_dir = File.dirname(absolute_path)
    zipped_tmp_file = "#{Dir.mktmpdir}/#{basename}.zip"
    `cd #{parent_dir} && zip -r #{zipped_tmp_file} #{basename}`
    zipped_tmp_file
  end
end

RSpec.configure { |c| c.include ZipHelpers }
