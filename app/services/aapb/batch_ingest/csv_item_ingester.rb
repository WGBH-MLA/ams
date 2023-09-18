require 'aapb/batch_ingest'

module AAPB
  module BatchIngest
    class CSVItemIngester < AAPB::BatchIngest::BatchItemIngester
      def ingest
        @works_ingested = []
        set_options
        @source_data = JSON.parse(@batch_item.source_data)
        ingest_object_at options, @source_data

        raise "Batch item contained invalid data.\n\n#{@batch_item.error}" unless @batch_item.error.nil?
        @works_ingested.first
      end

      private

      def object_list
        @object_list ||= {
          'Asset' => AssetResource,
          'PhysicalInstantiation' => PhysicalInstantiationResource,
          'DigitalInstantiation' => DigitalInstantiationResource,
          'EssenceTrack' => EssenceTrackResource,
          'Contribution' => ContributionResource
        }
      end

      def object_class_for(name)
        object_list[name]
      end

        # Removes a work without raising an exception
        def clean_failed_batch_item_work(work)
          work.destroy!
        rescue Ldp::Gone, ActiveFedora::ObjectNotFoundError => e
          # if it's already gone, continue without error.
        end

        def transaction
          Hyrax::Transactions::Container["work_resource.create_with_bulk_behavior"]
        end

        def transaction_create(model_object, user, ability, attributes)
          cx = Hyrax::Forms::ResourceForm.for(model_object).prepopulate!
          cx.validate(attributes)

          result = transaction
            .with_step_args(
              # "work_resource.add_to_parent" => {parent_id: @related_parents_parsed_mapping, user: user},
              "work_resource.add_bulkrax_files" => {files: [], user: user},
              "change_set.set_user_as_depositor" => {user: user},
              "work_resource.change_depositor" => {user: user},
              'work_resource.save_acl' => { permissions_params: [attributes.try('visibility') || 'open'].compact }
            )
            .call(cx)

          if result.failure?
            msg = result.failure[0].to_s
            msg += " - #{result.failure[1].full_messages.join(',')}" if result.failure[1].respond_to?(:full_messages)
            raise StandardError, msg, result.trace
          end

          result
        end
        def ingest_object_at(node, with_data, with_parent = false)
          actor = ::Hyrax::CurationConcern.actor
          user = User.find_by_email(@batch_item.submitter_email)
          ability = ::Ability.new(user)
          ingest_type = node.ingest_type

          attributes = if !with_parent
                         with_data[node.object_class]
                       else
                         solr_doc = SolrDocument.new(with_parent.to_solr)
                         with_data.merge(in_works_ids: [with_parent.id], title: solr_doc.title)
                       end

          attributes["admin_set_id"] = @batch_item.batch.admin_set_id

          if ingest_type == "new"
            model_object = object_class_for(node.object_class).new

            attributes = set_attributes_for_new_ingest_type(model_object, attributes, ability)

            actor_stack_status = transaction_create(model_object, user, ability, attributes)
          elsif ingest_type == "update"
            object_id = attributes.delete("id")

            unless model_object = object_class_for(node.object_class).find(object_id)
              raise("Unable to find object for `id` #{object_id}")
            end

            if model_object.is_a?(AssetResource)
              attributes = set_asset_objects_attributes(model_object, attributes, ingest_type)
            end

            actor_stack_status = transaction_create(model_object, user, ability, attributes)
          elsif ingest_type == "add"
            object_id = attributes.delete("id")
            unless model_object = object_class_for(node.object_class).find(object_id)
              raise("Unable to find object  for `id` #{object_id}")
            end

            if model_object.is_a?(AssetResource)
              attributes = set_asset_objects_attributes(model_object, attributes, ingest_type)
            end

            actor_stack_status = transaction_create(model_object, user, ability, attributes)
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
                # We won't always have data from the CSV for the children, so don't
                # fail if it is not included with the with_data
                with_data[c_node.object_class].each do |c_data|
                  ingest_object_at(c_node,c_data,parent_node)
                end unless with_data[c_node.object_class].nil?
              end
            end
            if model_object.errors.any?
              @batch_item.error = model_object.errors.messages.to_s
            end
          rescue => e
            # If there was an exception during ingest, ensure the related work
            # is destroyed.
            work_id = attributes.fetch(:in_works_ids, []).first
            work_id ||= model_object&.in_works_ids&.first if model_object

            if work_id
              work = Hyrax.query_service.find_by(id: work_id)
              asset_batch_id = work.admin_data.hyrax_batch_ingest_batch_id if work.admin_data
              child_batch_id = model_object.admin_data.hyrax_batch_ingest_batch_id if model_object.admin_data

              # make sure failed child object is from the same batch as parent
              if work && asset_batch_id == child_batch_id
                clean_failed_batch_item_work(work)
              end
            end

            # Re-raise the exception so it can be handled by downstream
            # exception handling e.g. the `rescue_from` block of
            # BatchItemIngestJob from hyrax-batch_ingest gem
            raise e
          end
        end

        def set_options
          @options = AAPB::BatchIngest::CSVConfigParser.validate_config reader_options
        end

        def reader_options
          Hyrax::BatchIngest.config.ingest_types[@batch_item.batch.ingest_type.to_sym].reader_options
        end

        def set_attributes_for_new_ingest_type(model_object, attributes, ability)
          new_attributes = attributes

          if model_object.is_a?(AssetResource)
            new_attributes["hyrax_batch_ingest_batch_id"] = batch_id
          end

          if new_attributes[:in_works_ids].present?
            new_attributes[:in_works_ids].each do |work_id|
              set_batch_ingest_id_on_related_asset(work_id, ability)
            end
          end

          new_attributes
        end

        def set_asset_objects_attributes(model_object, attributes, ingest_type)
          new_attributes = attributes
          admin_data = model_object.admin_data

          case ingest_type
          when 'update'
            # the AssetActor expects the env to include the admin_data values in order to keep them.
            # the AssetActor does not expect the existing Annotions unless Annotations are in the env.
            set_admin_data_attributes(admin_data, attributes)
            # annotations work the same for both update and add
            admin_data.annotations_attributes = attributes.delete('annotations')
            admin_data.save!
          when 'add'
            # serialized fields need to preserve exising data in an add ingest
            # handles asset, admin_data, and annotations
            new_attributes = add_asset_objects_attributes(model_object, attributes)
          end

          new_attributes
        end

        def set_batch_ingest_id_on_related_asset(work_id, ability)
          unless asset = Hyrax.query_service.find_by(id: work_id)
            raise 'Cannot find Asset with ID: #{work_id}.'
          end
          asset_actor = ::Hyrax::CurationConcern.actor
          asset_attrs = { hyrax_batch_ingest_batch_id: batch_id }
          asset_env = Hyrax::Actors::Environment.new(asset, ability, asset_attrs)
          asset_actor.update(asset_env)
        end

        def set_admin_data_attributes(admin_data, attributes)
          # add existing admin_data values so they're preserved in the AssetActor
          AdminData.attributes_for_update.each do |admin_attr|
            next unless attributes.keys.include?(admin_attr.to_s)
            admin_data.send("#{admin_attr}=", attributes[admin_attr.to_s])
          end
        end

        def add_asset_objects_attributes(model_object, attributes)
          new_attributes = attributes
debugger
          new_attributes.keys.each do |k|
            # If it is an annotations array, add existing annotations for the env
            # Skip @options.attributes check
            if k == 'annotations'
              annotations_objects = model_object.admin_data.annotations
              new_attributes[k] = annotations_objects.map{ |ann| { id: ann.id, annotation_type: ann.annotation_type, ref: ann.ref, source: ann.source, annotation: ann.annotation, version: ann.version, value: ann.value }.stringify_keys } + new_attributes[k]
            elsif @options.attributes.include?(k)
              admin_data_object = model_object.admin_data
              new_attributes[k] = (new_attributes[k] + model_object.try(k).to_a + admin_data_object.try(k).to_a ).uniq
            end
          end

          new_attributes
        end
    end
  end
end
