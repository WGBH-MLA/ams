# Generated via
#  `rails generate hyrax:work DigitalInstantiation`
module Hyrax
  module Actors
    class DigitalInstantiationActor < Hyrax::Actors::BaseActor
      def create(env)
        xml_file = File.read(env.attributes[:digital_instantiation_pbcore_xml].tempfile)
        pbcore_doc = PBCore::V2::InstantiationDocument.parse(xml_file)
        env = parse_pbcore_instantiation(env,pbcore_doc) if(env.attributes[:digital_instantiation_pbcore_xml])
        super
        parse_pbcore_essense_track(env,pbcore_doc)
      end

      private
        def parse_pbcore_instantiation(env,pbcore_doc)
          env.attributes[:date] = pbcore_doc.dates.map {|date| date.value} if pbcore_doc.dates
          env.attributes[:dimensions] = pbcore_doc.dimensions.map {|dimension| dimension.value}  if pbcore_doc.dimensions
          env.attributes[:standard] << pbcore_doc.standard.value  if pbcore_doc.standard
          env.attributes[:location] = pbcore_doc.location  if pbcore_doc.location && env.attributes[:location].empty?
          env.attributes[:media_type] = pbcore_doc.media_type.value  if pbcore_doc.media_type && env.attributes[:media_type].empty?
          env.attributes[:generations] = pbcore_doc.generations.map {|generation| generation.value}  if pbcore_doc.generations && env.attributes[:generations].empty?
          env.attributes[:file_size] = pbcore_doc.file_size.value  if pbcore_doc.file_size && env.attributes[:file_size].empty?
          env.attributes[:time_start] = pbcore_doc.time_start.value if pbcore_doc.time_start  if pbcore_doc.time_start && env.attributes[:time_start].empty?
          env.attributes[:duration] = pbcore_doc.duration  if pbcore_doc.duration && env.attributes[:duration].empty?
          env.attributes[:data_rate] = pbcore_doc.data_rate.value  if pbcore_doc.data_rate && env.attributes[:data_rate].empty?
          env.attributes[:colors] = pbcore_doc.colors.value if pbcore_doc.colors  if pbcore_doc.colors && env.attributes[:colors].empty?
          env.attributes[:language] = pbcore_doc.language.map {|lang| lang.value} if pbcore_doc.language && env.attributes[:language].empty?
          env
        end

        def parse_pbcore_essense_track(env,pbcore_doc)
          pbcore_doc.essence_tracks.each do |track|
            e = ::EssenceTrack.new
            e.title = env.curation_concern.title
            e.track_type = track.type  if track.type
            e.track_id << track.identifiers.map {|id| id.value}  if track.identifiers
            e.standard = track.standard.value if track.standard
            e.encoding = track.encoding.value if track.encoding
            e.data_rate = track.data_rate.value if track.data_rate
            e.frame_rate = track.frame_rate.value if track.frame_rate
            e.bit_depth = track.bit_depth if track.bit_depth
            e.aspect_ratio << track.aspect_ratio.value if track.aspect_ratio
            e.duration = track.duration if track.duration
            e.annotation << track.annotation.value if track.annotation
            e.save
            #add essence track as child work to digital instantiation
            env.curation_concern.members << e
            env.curation_concern.save
          end


        end

    end
  end
end
