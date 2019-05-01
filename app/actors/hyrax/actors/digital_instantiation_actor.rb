# Generated via
#  `rails generate hyrax:work DigitalInstantiation`
module Hyrax
  module Actors
    class DigitalInstantiationActor < Hyrax::Actors::BaseActor
      def create(env)
        if file_uploaded?(env)
          xml_file = uploaded_xml(env)
        else
          xml_file = env.attributes.delete(:pbcore_xml)
        end
        pbcore_doc = PBCore::InstantiationDocument.parse(xml_file)
        set_env_attributes_from_pbcore(env, pbcore_doc)
        save_instantiation_aapb_admin_data(env) && super && parse_pbcore_essense_track(env,pbcore_doc)
      end

      def update(env)
        if file_uploaded?(env)
          xml_file = uploaded_xml(env)
        else
          xml_file = env.attributes.delete(:pbcore_xml)
        end
        pbcore_doc = PBCore::InstantiationDocument.parse(xml_file)
        env = parse_pbcore_instantiation(env,pbcore_doc)
        save_instantiation_aapb_admin_data(env) && super && destroy_child_objects(env) && parse_pbcore_essense_track(env,pbcore_doc)
      end

      def destroy(env)
        destroy_instantiation_admin_data(env) && super
      end

      private

        def file_uploaded?(env)
          env.attributes[:digital_instantiation_pbcore_xml].respond_to?(:tempfile)
        end

        def uploaded_xml(env)
          File.read(env.attributes[:digital_instantiation_pbcore_xml].tempfile)
        end

        def destroy_child_objects(env)
          env.curation_concern.members.to_a.delete_if do |child|
            actor = Hyrax::CurationConcern.actor
            if actor.destroy(Actors::Environment.new(child, env.current_ability, {}))
              Hyrax.config.callback.run(:after_destroy, child.id, env.user)
              true
            end
          end
          env.curation_concern.reload
        end

        def set_env_attributes_from_pbcore(env, pbcore_doc)
          if !pbcore_doc.blank?
            env.attributes[:date] = pbcore_doc.dates.map(&:value) if pbcore_doc.dates && env.attributes[:dates].blank?
            env.attributes[:dimensions] = pbcore_doc.dimensions.map(&:value)  if pbcore_doc.dimensions && env.attributes[:dimensions].blank?
            env.attributes[:standard] = pbcore_doc.standard.value  if pbcore_doc.standard && env.attributes[:standard].blank?
            env.attributes[:location] = pbcore_doc.location.value  if pbcore_doc.location && env.attributes[:location].blank?
            env.attributes[:media_type] = pbcore_doc.media_type.value  if pbcore_doc.media_type && env.attributes[:media_type].blank?
            env.attributes[:generations] = pbcore_doc.generations.map(&:value)  if pbcore_doc.generations && env.attributes[:generations].blank?
            env.attributes[:file_size] = pbcore_doc.file_size.value  if pbcore_doc.file_size && env.attributes[:file_size].blank?
            # TODO: pbcore gem currently has time_starts, which is wrong.
            # It should be changed to time_start in the pbcore gem, but until then
            # just grab the first one.
            env.attributes[:time_start] = pbcore_doc.time_starts.first.value if pbcore_doc.time_starts.first && env.attributes[:time_start].blank?
            env.attributes[:duration] = pbcore_doc.duration.value  if pbcore_doc.duration && env.attributes[:duration].blank?
            env.attributes[:data_rate] = pbcore_doc.data_rate.value  if pbcore_doc.data_rate && env.attributes[:data_rate].blank?
            env.attributes[:colors] = pbcore_doc.colors.value  if pbcore_doc.colors && env.attributes[:colors].blank?
            env.attributes[:language] = pbcore_doc.languages.map(&:value) if pbcore_doc.languages && env.attributes[:language].blank?
            env.attributes[:tracks] = pbcore_doc.tracks.value if pbcore_doc.tracks  && env.attributes[:tracks].blank?
            env.attributes[:alternative_modes] = pbcore_doc.alternative_modes.value if pbcore_doc.alternative_modes  && env.attributes[:alternative_modes].blank?
            env.attributes[:channel_configuration] = pbcore_doc.channel_configuration.value if pbcore_doc.channel_configuration  && env.attributes[:channel_configuration].blank?

            # Do not set holding organization if it's already there (i.e. came in from the UI).
            unless env.attributes[:holding_organization]
              env.attributes[:holding_organization] = pbcore_doc.annotations.select { |annotation| annotation&.type&.downcase == 'organization' }.first&.value
            end

            env.attributes[:digital_format] = pbcore_doc.digital.value  if pbcore_doc.digital && env.attributes[:digital].blank?
            if pbcore_doc.identifiers
              pbcore_doc.identifiers.each do |id|
                env.attributes[:local_instantiation_identifier] = Array(id.value) if id.source == "AMS"
              end
            end
          end
        end

        def parse_pbcore_essense_track(env,pbcore_doc)
          if !pbcore_doc.nil?
            pbcore_doc.essence_tracks.each do |track|
              e = {}
              e[:title] = Array(env.curation_concern.title)
              e[:track_type] = track.type.value  if track.type
              e[:track_id] = track.identifiers.map(&:value) if track.identifiers
              e[:standard] = track.standard.value if track.standard
              e[:encoding] = track.encoding.value if track.encoding
              e[:data_rate] = track.data_rate.value if track.data_rate
              e[:frame_rate] = track.frame_rate.value if track.frame_rate
              e[:bit_depth] = track.bit_depth.value if track.bit_depth
              e[:frame_height] = parse_frame_height(track.frame_size.value) if track.frame_size
              e[:frame_width] = parse_frame_width(track.frame_size.value) if track.frame_size
              e[:aspect_ratio] = track.aspect_ratio.value if track.aspect_ratio
              e[:duration] = track.duration.value if track.duration
              e[:annotation] =  track.annotations.map(&:value) if track.annotations
              e[:admin_set_id] = env.curation_concern.admin_set_id
              e[:depositor] = env.curation_concern.depositor
              e[:date_uploaded] = env.curation_concern.date_uploaded
              e[:date_modified] = env.curation_concern.date_modified
              e[:access_control_id] = env.curation_concern.access_control_id
              actor = Hyrax::CurationConcern.actor
              essence_track = ::EssenceTrack.new
              if actor.create(Actors::Environment.new(essence_track, env.current_ability, e))
                #add essence track as child work to digital instantiation
                env.curation_concern.ordered_members << essence_track
                env.curation_concern.save
              end
            end
          end
          true
        end

        def parse_frame_width(frame_size)
          frame_size.split('x')[0].strip
        end

        def parse_frame_height(frame_size)
          frame_size.split('x')[1].strip
        end

        def save_instantiation_aapb_admin_data(env)
          env.curation_concern.instantiation_admin_data = find_or_create_instantiation_admin_data(env)
          set_instantiation_admin_data_attributes(env.curation_concern.instantiation_admin_data, env) if env.current_ability.can?(:create, InstantiationAdminData)
          remove_instantiation_admin_data_from_env_attributes(env)
        end

        def set_instantiation_admin_data_attributes(instantiation_admin_data, env)
          instantiation_admin_data_attributes.each do |k|
            instantiation_admin_data.send("#{k}=", env.attributes[k].to_s)
          end
        end

        def remove_instantiation_admin_data_from_env_attributes(env)
          instantiation_admin_data_attributes.each { |k| env.attributes.delete(k) }
        end

        def instantiation_admin_data_attributes
          # removing id, created_at & updated_at from attributes
          (InstantiationAdminData.attribute_names.dup - ['id', 'created_at', 'updated_at']).map &:to_sym
        end

        def find_or_create_instantiation_admin_data(env)
          instantiation_admin_data = if env.curation_concern.instantiation_admin_data_gid.blank?
                                       InstantiationAdminData.create
                                     else
                                       InstantiationAdminData.find_by_gid!(env.curation_concern.instantiation_admin_data_gid)
                                     end
          instantiation_admin_data
        end

        def destroy_instantiation_admin_data(env)
          env.curation_concern.instantiation_admin_data.destroy if env.curation_concern.instantiation_admin_data_gid
        end
    end
  end
end
