# frozen_string_literal: true
require 'ruby-progressbar'

module AMS
  class BackfillAssetValidationStatus < AMS::WorkReprocessor
    def initialize
      super(dir_name: 'backfill_asset_validation_status')
      @query = 'has_model_ssim:Asset -intended_children_count_isi:[* TO *]'
    end

    def run_on_id(id)
      solr_response = ActiveFedora::SolrService.get("id:#{id}", fl: [:admin_data_gid_ssim], rows: 1)
      asset_admin_data_gid = solr_response.dig('response', 'docs', 0, 'admin_data_gid_ssim', 0)
      admin_data = AdminData.find_by_gid!(asset_admin_data_gid)
      attrs_for_actor = {}

      raw_source_data = if admin_data.bulkrax_importer_id.present?
                          raw_data_from_bulkrax_entry(admin_data.bulkrax_importer_id, id)
                        elsif admin_data.hyrax_batch_ingest_batch_id.present?
                          raw_data_from_batch_item(admin_data.hyrax_batch_ingest_batch_id, id)
                        else
                          raise StandardError, "Unable to find source data for Asset #{id}"
                        end

      parsed_source_data = AAPB::BatchIngest::PBCoreXMLMapper.new(raw_source_data).asset_attributes
      attrs_for_actor['intended_children_count'] = parsed_source_data[:intended_children_count]
      if attrs_for_actor['intended_children_count'].blank?
        raise StandardError, "Unable to count intended children for Asset #{id}"
      end

      BackfillAssetValidationStatusJob.perform_later(id, attrs_for_actor)
    end

    def raw_data_from_bulkrax_entry(importer_id, asset_id)
      importer = Bulkrax::Importer.find(importer_id)
      matching_entries = importer.entries.select(:id).where("JSON_EXTRACT(parsed_metadata, '$.id') = '#{asset_id}'")
      raise StandardError, "Ambiguous data sources found for Asset #{asset_id}" if matching_entries.count > 1

      entry = Bulkrax::Entry.find(matching_entries.first.try(:id))
      ## NOTE:
      # As of 9 August, 2023, all Bulkrax entries in production are instances of Bulkrax::PbcoreXmlEntry, thus
      # we can safely assume that the data we're after won't be anywhere other than in `raw_metadata['pbcore_xml']`
      entry.raw_metadata['pbcore_xml']
    end

    def raw_data_from_batch_item(batch_id, asset_id)
      batch = Hyrax::BatchIngest::Batch.find(batch_id)
      ## NOTE:
      # As of 9 August, 2023, the logic to count the number of intended children an Asset should have has only
      # been applied to PBCore XML BatchIngests. Once this logic has been applied to other types of ingests
      # (CSV, etc.), this short-circuit should be removed and this class should be modified to extrac the data
      # from more than just PBCore XML.
      # @see https://github.com/scientist-softserv/ams/issues/9
      if batch.ingest_type != 'aapb_pbcore_zipped'
        raise StandardError, "Don't know how to count intended children when BatchIngest type is #{batch.ingest_type}"
      end

      batch_item = batch.batch_items.find_by(repo_object_id: asset_id)
      File.read(batch_item.source_location)
    end
  end
end
