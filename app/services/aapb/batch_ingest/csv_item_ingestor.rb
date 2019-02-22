require 'aapb/batch_ingest/batch_item_ingester'

module AAPB
  module BatchIngest
    class CSVItemIngestor < AAPB::BatchIngest::BatchItemIngester
      def ingest
        @works_ingested = []
        set_options
        @source_data = JSON.parse(@batch_item.source_data)
        ingest_object_at options, @source_data
        @works_ingested.first
      end

      private

        def ingest_object_at(node, with_data, with_parent = false)
          actor = ::Hyrax::CurationConcern.actor
          ability = ::Ability.new(User.find_by_email(@batch_item.submitter_email))

          attributes = if !with_parent
                         with_data[node.object_class]
                       else
                         solr_doc = SolrDocument.new(with_parent.to_solr)
                         with_data.merge(in_works_ids: [with_parent.id], title: solr_doc.title)
                       end

          attributes["admin_set_id"] = @batch_item.batch.admin_set_id

          if node.ingest_type == "new"
            model_object = node.object_class.constantize.new

            # If ingest is new add batch_id to Asset for tracking
            if model_object.is_a?(Asset)
              attributes["batch_id"] = batch_id
            elsif attributes[:in_works_ids].present?
              attributes[:in_works_ids].each do |work_id|
                unless asset = Asset.find(work_id)
                  raise 'Cannot find Asset with ID: #{work_id}.'
                end
                asset_actor = ::Hyrax::CurationConcern.actor
                asset_attrs = { batch_id: batch_id }
                asset_env = Hyrax::Actors::Environment.new(asset, ability, asset_attrs)
                asset_actor.update(asset_env)
              end
            end

            actor_stack_status = actor.create(::Hyrax::Actors::Environment.new(model_object, ability, attributes))

          elsif node.ingest_type == "update"
            object_id = attributes.delete("id")
            unless model_object = node.object_class.constantize.find(object_id)
              raise("Unable to find object  for `id` #{object_id}")
            end
            actor_stack_status = actor.update(::Hyrax::Actors::Environment.new(model_object, ability, attributes))
          end

          begin
            if actor_stack_status
              @batch_item.repo_object_id = model_object.id unless !with_parent
              @works_ingested << model_object.dup

              parent_node = if !with_parent
                              @works_ingested.last
                            else
                              with_parent
                            end

              node.children.each do |c_node|
                with_data[c_node.object_class].each do |c_data|
                  ingest_object_at(c_node,c_data,parent_node)
                end
              end
            end
          else
            @batch_item.error = model_object.errors.messages.to_s
          end
        end

        def set_options
          @options = AAPB::BatchIngest::CSVConfigParser.validate_config reader_options
        end

        def reader_options
          config = Hyrax::BatchIngest::Config.new
          config.ingest_types[@batch_item.batch.ingest_type.to_sym].reader_options.deep_dup
        end
    end
  end
end
