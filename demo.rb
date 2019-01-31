
require 'factory_bot'
include FactoryBot::Syntax::Methods

def build_pbcore
  build(
    :pbcore_description_document,
    :full_aapb,
    identifiers: [
      build(:pbcore_identifier, :aapb)
    ],
    contributors: build_list(:pbcore_contributor, 5),
    instantiations: [
      build_list(:pbcore_instantiation, 5, :digital),
      build(:pbcore_instantiation, :physical)
    ].flatten
  )
end

def zip_to_tmp(path)
  absolute_path = File.expand_path(path)
  basename = File.basename(absolute_path)
  parent_dir = File.dirname(absolute_path)
  zipped_tmp_file = "#{Dir.mktmpdir}/#{basename}.zip"
  `cd #{parent_dir} && zip -r #{zipped_tmp_file} #{basename}`
  zipped_tmp_file
end


@batch_pbcore = Array.new(20) { build_pbcore }
@batch_dir = './demo'
FileUtils.mkdir_p(@batch_dir)
@batch_pbcore.each do |pbcore|
  path = pbcore.identifiers.first.value.gsub('/', '_') + ".xml"
  File.open("#{@batch_dir}/#{path}", 'w') do |f|
    f << pbcore.to_xml
  end
end

@zipped = zip_to_tmp(@batch_dir)
