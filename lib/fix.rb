module Fix
  module RecordsMissingModels
    class << self

      def fix_one(guid)
        if old_url_record_exists?(guid)
          delete_solr_doc(guid)
          delete_new_url_record(guid)
          delete_new_url_tombstone(guid)
          reindex_old_url_record(guid)
        end
      end

      def fix_all
        find_all_guids.each do |guid|
          fix_one(guid)
        end
      end

      def solr
        Blacklight.default_index.connection
      end

      def find_all
        solr_docs = solr.select(params: {q: "-has_model_ssim:*", rows: 9999999})['response']['docs']
        # Filter out any solr docs with IDs that do not begin with "cpb-aacip" to help ensure
        # we do not accidentally removing Solr docs that don't represent AMS models.
        solr_docs.select { |solr_doc| solr_doc['id'] =~ /^cpb\-aacip/ }
      end

      def find_all_guids
        find_all.map { |solr_doc| solr_doc['id'] }
      end

      def old_url_record_exists?(guid)
        ActiveFedora.fedora.connection.get(old_url(guid)).response.status == 200
      end

      def af_base(guid)
        ActiveFedora::Base.find(guid)
      end

      def delete_solr_doc(guid)
        solr.commit if solr.delete_by_id(guid)
      end

      def delete_new_url_record(guid)
        af_base(guid).delete
      end

      def new_url(guid)
        "#{ActiveFedora.fedora.host}#{ActiveFedora.fedora.base_path}/#{::Noid::Rails.treeify(guid)}"
      end

      def old_url(guid)
        "#{ActiveFedora.fedora.host}#{ActiveFedora.fedora.base_path}/#{::Noid::Rails.treeify(guid, false)}"
      end

      def new_url_tombstone(guid)
        new_url(guid) + "/fcr:tombstone"
      end

      def delete_new_url_tombstone(guid)
        ActiveFedora.fedora.connection.delete(new_url_tombstone(guid))
      end

      def reindex_old_url_record(guid)
        Asset.find(guid).save!
      end
    end
  end
end
