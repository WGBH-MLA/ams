# frozen_string_literal: true

require 'dry/monads'

module Ams
  module Steps
    class AddDataFromPbcore
      include Dry::Monads[:result]
      attr_accessor :change_set, :user

      def call(change_set, user: nil)
        @change_set = change_set
        @user = user || User.find_by_user_key(change_set.depositor)
        case change_set.model
        when DigitalInstantiationResource
          update_change_set_from_pbcore
          # bulkrax handles its own essence tracks, thank you very much
          if change_set.bulkrax_identifier.blank?
            parse_pbcore_essense_track
          end
        end
        Success(change_set)
      end

      def add_data_from_pbcore
        update_change_set_from_pbcore
      end

      private

      def pbcore_doc
        @pbcore_doc ||= PBCore::InstantiationDocument.parse(xml_file)
      end

      def xml_file
        return @xml_file if @xml_file
        file_uploaded? ? uploaded_xml : change_set.input_params[:pbcore_xml]
      end

      def file_uploaded?
        change_set.input_params[:digital_instantiation_pbcore_xml].respond_to?(:tempfile)
      end

      def uploaded_xml
        File.read(change_set.input_params[:digital_instantiation_pbcore_xml].tempfile)
      end

      def update_change_set_from_pbcore
        if !pbcore_doc.blank?
          change_set[:date] = pbcore_doc.dates.map(&:value) if pbcore_doc.dates && change_set[:dates].blank?
          change_set[:dimensions] = pbcore_doc.dimensions.map(&:value)  if pbcore_doc.dimensions && change_set[:dimensions].blank?
          change_set[:standard] = pbcore_doc.standard.value  if pbcore_doc.standard && change_set[:standard].blank?
          change_set[:location] = pbcore_doc.location.value  if pbcore_doc.location && change_set[:location].blank?
          change_set[:media_type] = pbcore_doc.media_type.value  if pbcore_doc.media_type && change_set[:media_type].blank?
          change_set[:generations] = pbcore_doc.generations.map(&:value)  if pbcore_doc.generations && change_set[:generations].blank?
          change_set[:file_size] = pbcore_doc.file_size.value  if pbcore_doc.file_size && change_set[:file_size].blank?
          change_set[:time_start] = pbcore_doc.time_start.value if pbcore_doc.time_start && change_set[:time_start].blank?
          change_set[:duration] = pbcore_doc.duration.value  if pbcore_doc.duration && change_set[:duration].blank?
          change_set[:data_rate] = pbcore_doc.data_rate.value  if pbcore_doc.data_rate && change_set[:data_rate].blank?
          change_set[:colors] = pbcore_doc.colors.value  if pbcore_doc.colors && change_set[:colors].blank?
          change_set[:language] = pbcore_doc.languages.map(&:value) if pbcore_doc.languages && change_set[:language].blank?
          change_set[:tracks] = pbcore_doc.tracks.value if pbcore_doc.tracks  && change_set[:tracks].blank?
          change_set[:alternative_modes] = pbcore_doc.alternative_modes.value if pbcore_doc.alternative_modes  && change_set[:alternative_modes].blank?
          change_set[:channel_configuration] = pbcore_doc.channel_configuration.value if pbcore_doc.channel_configuration  && change_set[:channel_configuration].blank?

          # Do not set holding organization if it's already there (i.e. came in from the UI).
          unless change_set[:holding_organization]
            change_set[:holding_organization] = pbcore_doc.annotations.select { |annotation| annotation&.type&.downcase == 'organization' }.first&.value
          end

          change_set[:digital_format] = pbcore_doc.digital.value  if pbcore_doc.digital && change_set[:digital].blank?
          if pbcore_doc.identifiers
            pbcore_doc.identifiers.each do |id|
              change_set[:local_instantiation_identifier] = Array(id.value) if id.source == "AMS"
            end
          end
        end
      end

      def parse_pbcore_essense_track
        if !pbcore_doc.nil?
          pbcore_doc.essence_tracks.each do |track|
            e = {}
            e[:title] = Array(change_set.title)
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
            e[:admin_set_id] = change_set.admin_set_id
            e[:depositor] = change_set.depositor
            e[:date_uploaded] = change_set.date_uploaded
            e[:date_modified] = change_set.date_modified

            result = create_essence_track(e)
            essence_track = result.value! if result.success?
            change_set.member_ids += [essence_track.id] if essence_track
          end
        end
        true
      end

      def create_essence_track(attrs)
        cx = Hyrax::Forms::ResourceForm.for(EssenceTrackResource.new).prepopulate!
        cx.validate(attrs)
        Hyrax::Transactions::Container["work_resource.create_with_bulk_behavior"]
          .with_step_args(
            "work_resource.add_bulkrax_files" => {files: [], user: user},

            "change_set.set_user_as_depositor" => {user: user},
            "work_resource.change_depositor" => {user: user},
            'work_resource.save_acl' => { permissions_params: [attrs.try('visibility') || 'open'].compact }
          )
          .call(cx)
      end

      def parse_frame_width(frame_size)
        frame_size.split('x')[0].strip
      end

      def parse_frame_height(frame_size)
        frame_size.split('x')[1].strip
      end
    end
  end
end
