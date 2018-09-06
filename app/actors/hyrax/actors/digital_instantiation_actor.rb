# Generated via
#  `rails generate hyrax:work DigitalInstantiation`
module Hyrax
  module Actors
    class DigitalInstantiationActor < Hyrax::Actors::BaseActor
      def create(env)
        xml_file = File.read(env.attributes[:digital_instantiation_pbcore_xml].tempfile)
        pbcore_doc = PBCore::V2::InstantiationDocument.parse(xml_file)
        env = parse_pbcore_instantiation(env,pbcore_doc) if(env.attributes[:digital_instantiation_pbcore_xml])
        super && parse_pbcore_essense_track(env,pbcore_doc)
      end

      def update(env)
        xml_file = File.read(env.attributes[:digital_instantiation_pbcore_xml].tempfile)
        pbcore_doc = PBCore::V2::InstantiationDocument.parse(xml_file)
        env = parse_pbcore_instantiation(env,pbcore_doc) if(env.attributes[:digital_instantiation_pbcore_xml])
        super && destroy_child_objects(env) && parse_pbcore_essense_track(env,pbcore_doc)
      end

      private
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

        def parse_pbcore_instantiation(env,pbcore_doc)
          env.attributes[:date] = pbcore_doc.dates.map {|date| date.value} if pbcore_doc.dates && env.attributes[:dates].blank?
          env.attributes[:dimensions] = pbcore_doc.dimensions.map {|dimension| dimension.value}  if pbcore_doc.dimensions && env.attributes[:dimensions].blank?
          (env.attributes[:standard] ||= []) << pbcore_doc.standard.value  if pbcore_doc.standard && env.attributes[:standard].blank?
          env.attributes[:location] = pbcore_doc.location  if pbcore_doc.location && env.attributes[:location].blank?
          env.attributes[:media_type] = pbcore_doc.media_type.value  if pbcore_doc.media_type && env.attributes[:media_type].blank?
          env.attributes[:generations] = pbcore_doc.generations.map {|generation| generation.value}  if pbcore_doc.generations && env.attributes[:generations].blank?
          env.attributes[:file_size] = pbcore_doc.file_size.value  if pbcore_doc.file_size && env.attributes[:file_size].blank?
          env.attributes[:time_start] = pbcore_doc.time_start.value if pbcore_doc.time_start && env.attributes[:time_start].blank?
          env.attributes[:duration] = pbcore_doc.duration  if pbcore_doc.duration && env.attributes[:duration].blank?
          env.attributes[:data_rate] = pbcore_doc.data_rate.value  if pbcore_doc.data_rate && env.attributes[:data_rate].blank?
          env.attributes[:colors] = pbcore_doc.colors.value  if pbcore_doc.colors && env.attributes[:colors].blank?
          env.attributes[:language] = pbcore_doc.language.map {|lang| lang.value} if pbcore_doc.language && env.attributes[:language].blank?
          env.attributes[:tracks] = pbcore_doc.tracks if pbcore_doc.tracks  && env.attributes[:tracks].blank?
          env.attributes[:alternative_modes] = pbcore_doc.alternative_modes if pbcore_doc.alternative_modes  && env.attributes[:alternative_modes].blank?
          env.attributes[:channel_configuration] = pbcore_doc.channel_configuration if pbcore_doc.channel_configuration  && env.attributes[:channel_configuration].blank?
          env.attributes[:digital_format] = pbcore_doc.digital.value  if pbcore_doc.digital && env.attributes[:digital].blank?
          if pbcore_doc.identifiers
            pbcore_doc.identifiers.map do |id|
              env.attributes[:local_instantiation_identifer] = Array(id.value) if id.source == "AMS"
            end
          end
          env
        end

        def parse_pbcore_essense_track(env,pbcore_doc)
          pbcore_doc.essence_tracks.each do |track|
            e = {}
            e[:title] = Array(env.curation_concern.title)
            e[:track_type] = track.type  if track.type
            e[:track_id] = Array(track.identifiers.map {|id| id.value})  if track.identifiers
            e[:standard] = track.standard.value if track.standard
            e[:encoding] = track.encoding.value if track.encoding
            e[:data_rate] = track.data_rate.value if track.data_rate
            e[:frame_rate] = track.frame_rate.value if track.frame_rate
            e[:bit_depth] = track.bit_depth if track.bit_depth
            e[:aspect_ratio] = Array(track.aspect_ratio.value) if track.aspect_ratio
            e[:duration] = track.duration if track.duration
            e[:annotation] =  Array(track.annotation.value) if track.annotation
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

    end
  end
end
