require_relative '../../config/environment'

module Fix
  class ChangeMediaType
    MEDIA_TYPES = MediaTypeService.new.select_all_options

    attr_reader :aapb_ids_filename, :aapb_ids
    def initialize
      @aapb_ids_filename = "#{File.dirname(File.expand_path(__FILE__))}/data/nebraska_public_media_ids.txt"
    end

    def aapb_ids
      @aapb_ids ||= File.readlines(aapb_ids_filename).map(&:strip)
    end

    def asset_resources
      @asset_resources ||= aapb_ids.map do |aapb_id|
        puts "Looking up Asset #{aapb_id} ..."
        begin
          AssetResource.find(aapb_id)
        rescue => e
          puts "Error looking up Asset #{aapb_id}: #{e.class} -- #{e.message}"
        end
      end.compact
    end

    def run!
      puts "Running Hotfix #{self.class.name} ..."
      asset_resources.each do |asset_resource|
        pi = asset_resource.physical_instantiation_resources.detect  { |pi| pi.media_type != 'Moving Image' }
        if !pi
          puts "Nothing to fix for AssetResource #{asset_resource.id}, skipping ..."
          next
        end

        # Change the metadata
        pi.media_type = 'Moving Image'

        begin
          pi.save
          puts "PhysicalInstantiationResource #{pi.id} saved with media_type 'Moving Image'"
        rescue => e
          puts "Error saving PhysicalInstantiationResource #{pi.id}: #{e.class} -- #{e.message}"
        end
      end
    end
  end
end


if __FILE__ == $0
  Fix::ChangeMediaType.new.run!
end
