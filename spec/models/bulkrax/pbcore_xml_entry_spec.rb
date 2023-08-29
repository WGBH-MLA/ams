# frozen_string_literal: true

require 'rails_helper'

module Bulkrax
  RSpec.describe PbcoreXmlEntry, type: :model do
    let(:path) { './spec/fixtures/bulkrax/xml/pbcore_doc.xml' }
    let(:data) { described_class.read_data(path) }
    let(:source_identifier) { 'pbcoreIdentifier' }

    describe 'class methods' do
      context '#read_data' do
        it 'reads the data from an xml file' do
          expect(described_class.read_data(path)).to be_a(Nokogiri::XML::Document)
        end
      end

      context '#data_for_entry' do
        it 'retrieves the data and constructs a hash' do
          expect(described_class.data_for_entry(data, source_identifier)).to eq(
            {"pbcoreIdentifier"=>"cpb-aacip-20-000000hr",
              :delete=>nil,
              :data=>
              "<pbcoreDescriptionDocument schemaLocation=\"http://www.pbcore.org/PBCore/PBCoreNamespace.html http://www.pbcore.org/xsd/pbcore-2.0.xsd\" xmlns=\"http://www.w3.org/2001/XMLSchema-instance\"> <pbcoreAssetDate dateType=\"created\">1996-05-11</pbcoreAssetDate> <pbcoreIdentifier source=\"http://americanarchiveinventory.org\">cpb-aacip/20-000000hr</pbcoreIdentifier> <pbcoreIdentifier source=\"Librarian\">4344</pbcoreIdentifier> <pbcoreIdentifier source=\"Sony Ci\">d74384e6424246088871415afe6230f5</pbcoreIdentifier> <pbcoreTitle titleType=\"Series\">Houston Symphony</pbcoreTitle> <pbcoreDescription>5/11/96</pbcoreDescription> <pbcoreDescription descriptionType=\"Series Description\">Houston Symphony is a series of live recordings of the Houston Symphony orchestral performances.</pbcoreDescription> <pbcoreGenre source=\"AAPB Topical Genre\">Music</pbcoreGenre> <pbcoreGenre source=\"AAPB Format Genre\">Performance for a Live Audience</pbcoreGenre> <pbcoreCreator> <creator>Magistrelli, Mark</creator> <creatorRole>Writer</creatorRole> </pbcoreCreator> <pbcoreCreator> <creator>King, Dr. James C.</creator> <creatorRole>Executive Producer</creatorRole> </pbcoreCreator> <pbcoreCreator> <creator>Cincinnati Public Radio</creator> <creatorRole>Producing Organization</creatorRole> </pbcoreCreator> <pbcoreContributor> <contributor>Clooney, Nick, 1934-</contributor> <contributorRole>Host</contributorRole> </pbcoreContributor> <pbcorePublisher> <publisher>Prairie Public Broadcasting, Inc.</publisher> <publisherRole>Publisher</publisherRole> </pbcorePublisher> <pbcoreInstantiation> <instantiationIdentifier source=\"Librarian\">4344</instantiationIdentifier> <instantiationPhysical>DAT</instantiationPhysical> <instantiationLocation>KUHF audio library</instantiationLocation> <instantiationMediaType>Sound</instantiationMediaType> <instantiationGenerations>Original</instantiationGenerations> <instantiationDuration>02:00:00?</instantiationDuration> <instantiationChannelConfiguration>Two Track Stereo</instantiationChannelConfiguration> <instantiationAnnotation annotationType=\"organization\">KUHF-FM</instantiationAnnotation> <instantiationExtension> <extensionWrap> <extensionElement>AACIP Record Nomination Status</extensionElement> <extensionValue>Nominated/2nd Priority</extensionValue> <extensionAuthorityUsed>AACIP</extensionAuthorityUsed> </extensionWrap> </instantiationExtension> </pbcoreInstantiation> <pbcoreInstantiation> <instantiationIdentifier source=\"mediainfo\">cpb-aacip-20-000000hr.wav</instantiationIdentifier> <instantiationDate dateType=\"encoded\">2013-05-07</instantiationDate> <instantiationDigital>audio/vnd.wave</instantiationDigital> <instantiationStandard>Wave</instantiationStandard> <instantiationLocation>N/A</instantiationLocation> <instantiationMediaType>Sound</instantiationMediaType> <instantiationGenerations>Preservation Master</instantiationGenerations> <instantiationFileSize unitsOfMeasure=\"GiB\">1</instantiationFileSize> <instantiationDataRate unitsOfMeasure=\"Kbps\">1489</instantiationDataRate> <instantiationTracks>1 audio</instantiationTracks> <instantiationChannelConfiguration>2 channel</instantiationChannelConfiguration> <instantiationEssenceTrack> <essenceTrackType>audio</essenceTrackType> <essenceTrackIdentifier source=\"mediainfo\">0</essenceTrackIdentifier> <essenceTrackEncoding ref=\"http://www.microsoft.com/windows/\" source=\"mediainfo\">PCM</essenceTrackEncoding> <essenceTrackDataRate unitsOfMeasure=\"Kbps\">1411</essenceTrackDataRate> <essenceTrackSamplingRate>44.1 KHz</essenceTrackSamplingRate> <essenceTrackBitDepth>16</essenceTrackBitDepth> <essenceTrackDuration>01:54:18</essenceTrackDuration> </instantiationEssenceTrack> <instantiationAnnotation annotationType=\"organization\">American Archive of Public Broadcasting</instantiationAnnotation> </pbcoreInstantiation> <pbcoreInstantiation> <instantiationIdentifier source=\"mediainfo\">cpb-aacip-20-000000hr.mp3</instantiationIdentifier> <instantiationDate dateType=\"encoded\">2013-05-07</instantiationDate> <instantiationDigital>audio/mpeg</instantiationDigital> <instantiationStandard>MPEG Audio</instantiationStandard> <instantiationLocation>N/A</instantiationLocation> <instantiationMediaType>Sound</instantiationMediaType> <instantiationGenerations>Proxy</instantiationGenerations> <instantiationFileSize unitsOfMeasure=\"MiB\">104</instantiationFileSize> <instantiationDataRate unitsOfMeasure=\"Kbps\">128</instantiationDataRate> <instantiationTracks>1 audio</instantiationTracks> <instantiationChannelConfiguration>2 channel</instantiationChannelConfiguration> <instantiationEssenceTrack> <essenceTrackType>audio</essenceTrackType> <essenceTrackIdentifier source=\"mediainfo\">0</essenceTrackIdentifier> <essenceTrackEncoding source=\"mediainfo\">MPEG-1 Audio layer 3</essenceTrackEncoding> <essenceTrackDataRate unitsOfMeasure=\"Kbps\">128</essenceTrackDataRate> <essenceTrackSamplingRate>44.1 KHz</essenceTrackSamplingRate> <essenceTrackDuration>01:54:18</essenceTrackDuration> </instantiationEssenceTrack> <instantiationAnnotation annotationType=\"encoded by\">Fraunhofer IIS MP3 v04.01.02 (high quality)</instantiationAnnotation> <instantiationAnnotation annotationType=\"organization\">American Archive of Public Broadcasting</instantiationAnnotation> </pbcoreInstantiation> <pbcoreAnnotation annotationType=\"Level of User Access\">On Location</pbcoreAnnotation> <pbcoreAnnotation annotationType=\"Transcript Status\">Uncorrected</pbcoreAnnotation> <pbcoreAnnotation annotationType=\"last_modified\">2015-02-18 08:32:48</pbcoreAnnotation> <pbcoreAnnotation annotationType=\"organization\">KUHF-FM</pbcoreAnnotation></pbcoreDescriptionDocument>",
              :collection=>[],
              :children=>[]}
          )
        end
      end
    end

    describe 'deleted' do
      subject(:xml_entry) { described_class.new(importerexporter: importer) }
      let(:path) { './spec/fixtures/bulkrax/xml/deleted.xml' }
      let(:raw_metadata) { described_class.data_for_entry(data, source_identifier) }
      let(:importer) do
        i = FactoryBot.create(:bulkrax_importer_pbcore_xml)
        i.current_run
        i
      end
      let(:object_factory) { instance_double(ObjectFactory) }

      before do
        Bulkrax.field_mappings.merge!(
          'PbcoreXmlParser' => {
            'record_element' => 'pbcoreDescriptionDocument'
          }
        )
      end

      it 'parses the delete as true if present' do
        expect(raw_metadata[:delete]).to be_truthy
      end
    end

    describe '#build' do
      subject(:xml_entry) { described_class.new(importerexporter: importer) }
      let(:raw_metadata) { described_class.data_for_entry(data, source_identifier) }
      let(:importer) do
        i = FactoryBot.create(:bulkrax_importer_pbcore_xml)
        i.field_mapping['source'] = { from: ['pbcoreIdentifier'], source_identifier: true } if App.rails_5_1?
        i.current_run
        i
      end
      let(:object_factory) { instance_double(ObjectFactory) }

      before do
        Bulkrax.field_mappings.merge!(
          'PbcoreXmlParser' => {
            'record_element' => 'pbcoreDescriptionDocument'
          }
        )
      end

      it 'parses the delete as nil if it is not present' do
        expect(raw_metadata[:delete]).to be_nil
      end

      context 'with raw_metadata' do
        before do
          xml_entry.raw_metadata = raw_metadata
          allow(ObjectFactory).to receive(:new).and_return(object_factory)
          allow(object_factory).to receive(:run!).and_return(instance_of(Asset))
          allow(User).to receive(:batch_user)
        end

        it 'succeeds' do
          xml_entry.build
          expect(xml_entry.status).to eq('Complete')
        end

        it 'builds entry' do
          xml_entry.build
          expect(xml_entry.parsed_metadata).to eq(
            {
              "admin_set_id"=>"MyString",
              "bulkrax_identifier"=>"cpb-aacip-20-000000hr",
              "children"=>[],
              "delete"=>nil,
              "file"=>nil,
              "model"=>nil,
              "rights_statement"=>[nil],
              "visibility"=>"open"
            }
          )
        end

        context 'with asset raw_metadata' do
          let(:raw_metadata) {
            {
              "annotations"=>
            [{"ref"=>nil,
              "annotation_type"=>"level_of_user_access",
              "source"=>nil,
              "value"=>"On Location",
              "annotation"=>nil,
              "version"=>nil},
             {"ref"=>nil,
              "annotation_type"=>"transcript_status",
              "source"=>nil,
              "value"=>"Uncorrected",
              "annotation"=>nil,
              "version"=>nil},
             {"ref"=>nil,
              "annotation_type"=>"last_modified",
              "source"=>nil,
              "value"=>"2015-02-18 08:32:48",
              "annotation"=>nil,
              "version"=>nil},
             {"ref"=>nil,
              "annotation_type"=>"organization",
              "source"=>nil,
              "value"=>"KUHF-FM",
              "annotation"=>nil,
              "version"=>nil}],
           "id"=>"cpb-aacip-20-000000hr",
           "series_title"=>["Houston Symphony"],
           "description"=>["5/11/96"],
           "episode_description"=>[],
           "series_description"=>
            ["Houston Symphony is a series of live recordings of the Houston Symphony orchestral performances."],
           "program_description"=>[],
           "segment_description"=>[],
           "clip_description"=>[],
           "promo_description"=>[],
           "raw_footage_description"=>[],
           "date"=>[],
           "broadcast_date"=>[],
           "copyright_date"=>[],
           "created_date"=>["1996-05-11"],
           "audience_level"=>[],
           "audience_rating"=>[],
           "asset_types"=>[],
           "genre"=>["Performance for a Live Audience"],
           "topics"=>["Music"],
           "rights_summary"=>[],
           "rights_link"=>[],
           "local_identifier"=>["4344"],
           "pbs_nola_code"=>[],
           "sonyci_id"=>["d74384e6424246088871415afe6230f5"],
           "subject"=>[],
           "contributors"=>[],
           "producing_organization"=>[],
           "model"=>"Asset",
           "bulkrax_identifier"=>"1-Asset-0-1"
            }
          }

          it 'builds entry' do
            xml_entry.build
            expect(xml_entry.parsed_metadata).to eq(
              {
                "bulkrax_identifier"=>"1-Asset-0-1",
                "bulkrax_importer_id"=>1,
                "model"=>"Asset",
                "id"=>"cpb-aacip-20-000000hr",
                "series_title"=>["Houston Symphony"],
                "description"=>["5/11/96"],
                "episode_description"=>[],
                "series_description"=>
                 ["Houston Symphony is a series of live recordings of the Houston Symphony orchestral performances."],
                "program_description"=>[],
                "segment_description"=>[],
                "clip_description"=>[],
                "promo_description"=>[],
                "raw_footage_description"=>[],
                "date"=>[],
                "broadcast_date"=>[],
                "copyright_date"=>[],
                "created_date"=>["1996-05-11"],
                "audience_level"=>[],
                "audience_rating"=>[],
                "asset_types"=>[],
                "genre"=>["Performance for a Live Audience"],
                "topics"=>["Music"],
                "rights_summary"=>[],
                "rights_link"=>[],
                "local_identifier"=>["4344"],
                "pbs_nola_code"=>[],
                "subject"=>[],
                "producing_organization"=>[],
                "visibility"=>"open",
                "rights_statement"=>[nil],
                "admin_set_id"=>"MyString",
                "file"=>nil,
                "admin_data_gid"=>"gid://ams/admindata/1"
              }
            )
          end
        end

        it 'does not add unsupported fields' do
          xml_entry.build
          expect(xml_entry.parsed_metadata).not_to include('abstract')
          expect(xml_entry.parsed_metadata).not_to include('Lorem ipsum dolor sit amet.')
        end
      end

      context 'without raw_metadata' do
        before do
          xml_entry.raw_metadata = nil
        end

        it 'fails' do
          xml_entry.build
          expect(xml_entry.status).to eq('Failed')
        end
      end
    end
  end
end
