class ChangeSoundToMovingImage
  attr_reader :aapb_ids_filename, :aapb_ids, :errors
  def initialize(aapb_ids_filename=DEFAULT_AAPB_IDS_FILENAME)
    @aapb_ids_filename = "#{File.dirname(File.expand_path(__FILE__))}/asset_resource_ids.txt"
    @errors = {}
  end

  def aapb_ids
    @aapb_ids ||= File.readlines(aapb_ids_filename).map(&:strip)
  end

  def asset_resources
    @asset_resources ||= aapb_ids.map do |aapb_id|
      puts "Looking up Asset #{aapb_id} ..."
      asset_resource = begin
        AssetResource.find(aapb_id)
      rescue => e
        puts "Error looking up Asset #{aapb_id}: #{e.class} -- #{e.message}"
        errors[aapb_id] ||= []
        errors[aapb_id] << e
      end
      [ aapb_id, asset_resource ]
    end.to_h
  end
end

if __FILE__ == $0
  cstm = ChangeSoundToMovingImage.new
  puts "cstm.asset_resources: #{cstm.asset_resources}"
end
