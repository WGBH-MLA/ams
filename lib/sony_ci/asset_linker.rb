module SonyCi
  class AssetLinker

    # Readers for instance vars
    attr_reader :asset_ids
    attr_accessor :successes, :failures

    # Initializes a new instance of the AssetLinker class.
    # @param [Array] asset_ids The list of Asset IDs to link to Sony Ci media.
    def initialize(asset_ids: [])
      @asset_ids = asset_ids
      # Create a hash to store the results of the linking process, with Asset
      # IDs as keys and Sony Ci IDs or error messages as values.
      @successes = {}
      @failures = {}
    end

    # Returns an array of AssetResource objects corresponding to the Asset IDs.
    # @return [Array<AssetResource>] The AssetResource objects corresponding to the Asset IDs.
    def asset_resources
      @asset_resources ||= asset_ids.map do |asset_id|
        AssetResource.find(asset_id)
      rescue => error
        # If not found, add the error to the results. Do not include in the returned array.
        failures[asset_id] = error
        nil
      end.compact
    end


    def link_assets!
      asset_resources.each do |asset_resource|
        successes[asset_resource.id.to_s]  = asset_resource.link_to_sony_ci_asset!
      rescue => error
        failures[asset_resource.id.to_s] = error
      end
    end
  end
end