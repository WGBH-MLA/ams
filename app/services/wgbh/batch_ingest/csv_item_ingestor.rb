module WGBH
  module BatchIngest
    class CSVItemIngestor < Hyrax::BatchIngest::BatchItemIngester

      def ingest
        source_data = JSON.parse(@batch_item.source_data)
        # create asset first

        actor = ::Hyrax::CurationConcern.actor
        asset = ::Asset.new
        ability = ::Ability.new(User.find_by_email "wgbh_admin@wgbh-mla.org")
        begin
        if actor.create(::Hyrax::Actors::Environment.new(asset, ability,source_data["Asset"]))
          @batch_item.repo_object_id = asset.id
        else
          @batch_item.error = asset.errors.messages.to_s
        end

        asset.save

        # create any other model
        #
        source_data.delete("Asset")

        source_data.each_pair do |model,model_objects|

          #raise "Invalid child type #{model} for Asset" unless model == "Contribution" or ::Asset.valid_child_concerns.include?(model.constantize)

          model_objects.each do |attribute_array|
            attr = attribute_array.first
            #skip empty objects
            next if attr.except("admin_set_id").blank?

            modelObject = model.constantize.new
            actor = ::Hyrax::CurationConcern.actor

            # Enforcing parent title
            asset_solr_doc = SolrDocument.new(asset.to_solr)
            attr["title"] = asset_solr_doc.title
            attr["in_works_ids"] = [asset.id]

            if actor.create(::Hyrax::Actors::Environment.new(modelObject, ability,attr))
              next
            else
              @batch_item.error = @batch_item.error.to_s + "\n#{model} ==> " + modelObject.errors.messages.to_s
            end

          end

        end

        rescue StandardError => e
          raise Hyrax::BatchIngest::ReaderError,"Unable to process item, error: #{e.message} at #{e.backtrace_locations}"
        end

        return asset
      end
    end
  end
end
