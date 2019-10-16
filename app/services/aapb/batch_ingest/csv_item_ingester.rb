require 'aapb/batch_ingest'

module AAPB
  module BatchIngest
    class CSVItemIngester < AAPB::BatchIngest::BatchItemIngester
      def ingest
        @works_ingested = []
        set_options
        @source_data = JSON.parse(@batch_item.source_data)
        ingest_object_at options, @source_data
        @works_ingested.first
      end

      private

        def clean_failed_batch_item(works_ids, model_obj)
          obj = Asset.find(works_ids.first) if works_ids && works_ids.present?

          unless obj
            obj = model_obj.is_a?(Asset) ? model_obj : (model_obj.in_works_ids.present? ? Asset.find(model_obj.in_works_ids.first) : nil)
          end

          if obj
            # lol
            begin
              obj.destroy!
            rescue Ldp::Gone => e
              # rescue because the asset itself being destroyed is throwing Ldp::Gone
            end
          end
        end

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
              attributes["hyrax_batch_ingest_batch_id"] = batch_id
            end

            if attributes[:in_works_ids].present?
              attributes[:in_works_ids].each do |work_id|
                unless asset = Asset.find(work_id)
                  raise 'Cannot find Asset with ID: #{work_id}.'
                end
                asset_actor = ::Hyrax::CurationConcern.actor
                asset_attrs = { hyrax_batch_ingest_batch_id: batch_id }
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
          elsif node.ingest_type == "add"
            object_id = attributes.delete("id")
            unless model_object = node.object_class.constantize.find(object_id)
              raise("Unable to find object  for `id` #{object_id}")
            end

            attributes.keys.each do |k|
              if @options.attributes.include?(k)
                if model_object.is_a?(Asset)
                  admin_data_object = model_object.admin_data
                  attributes[k] = (attributes[k] + model_object.try(k).to_a + admin_data_object.try(k).to_a ).uniq
                end
              end
            end
            actor_stack_status = actor.update(::Hyrax::Actors::Environment.new(model_object, ability, attributes))
          end

          # catch sub-Asset ingest failures here, where we have attributes, cleanup, then re-raise to enable rescue_from to properly update failed batch item etc
          begin
            if actor_stack_status
              @batch_item.repo_object_id = model_object.id unless !with_parent
              @works_ingested << model_object.dup

              parent_node = if !with_parent
                              @works_ingested.last
                            else
                              with_parent
                            end

              # ingest asset's childrens
              node.children.each do |c_node|
                with_data[c_node.object_class].each do |c_data|
                  ingest_object_at(c_node,c_data,parent_node)
                end
              end
            end
            if model_object.errors.any?
              @batch_item.error = model_object.errors.messages.to_s
            end

          rescue Exception => e
            clean_failed_batch_item(attributes[:in_works_ids], model_object)
            raise e
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
