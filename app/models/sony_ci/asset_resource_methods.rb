module SonyCi::AssetResourceMethods
  # Links the AssetResource to a Sony Ci Asset by searching for Sony Ci Assets
  # that match the AssetResource's ID.
  # @return [Array] Returns the list of linked Sony Ci IDs, usually just one, but
  # possibly multiple.
  def link_to_sony_ci_asset!
    # Set the sony ci ID in the Admin Data record and save it independently
    admin_data.sonyci_id = found_sony_ci_ids
    admin_data.save!
    # Save AssetResource which re-indexes the updated Sony Ci IDs
    save!
    admin_data.sonyci_id
  end

  # @return [Array] Returns the list of Sony Ci IDs from the list of found Sony Ci Assets
  def found_sony_ci_ids
    found_sony_ci_assets.map { |ci_asset| ci_asset['id'] }
  end

  # @return [Array] Returns the list of found Sony Ci Assets that match the Asset ID
  def found_sony_ci_assets
    sony_ci_api.workspace_search(
      query: id_query_str,
      kind: "Asset"
    ).select do |result|
      result['type'].in? ['Video', 'Audio']
    end
  end

  def id_query_str
    id.to_s[-20..-1]
  end

  def sony_ci_api
    @sony_ci_api ||= SonyCiApi::Client.new('config/ci.yml')
  end
end