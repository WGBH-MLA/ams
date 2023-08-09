require 'rails_helper'

describe SolrDocument do
  let(:solr_document) { described_class.new }
  let(:asset) { create(:asset, :with_physical_digital_and_essence_track) }
  let(:asset_solr_doc) { SolrDocument.find(asset.id) }

  describe '#title' do
    context 'when other titles are present' do
      let(:other_titles) do
        {
          program_title: 'test program title',
          episode_number: '123',
          episode_title: 'test episode title',
          segment_title: 'test segment title',
          clip_title: 'test clip title',
          promo_title: 'test promo title',
          raw_footage_title: 'test raw footage title',
        }
      end

      context 'when all other titles are present' do
        before do
          other_titles.each { |k,v| allow(solr_document).to receive(k).and_return(v) }
        end

        it 'displays all titles concatenated together with a semicolon' do
          expect(solr_document.title).to eq [other_titles.values.join('; ') ]
        end
      end

      context 'when a subset of titles are present' do
        # Take a random sampling of other titles, preserving the order.
        let(:subset_of_other_titles) { other_titles.select { rand(2) == 0 } }
        before do
          subset_of_other_titles.each { |k,v| allow(solr_document).to receive(k).and_return(v) }
        end
        it 'only displays titles that are present, concatenated with a semicolon' do
          expect(solr_document.title).to eq [ subset_of_other_titles.values.join('; ') ]
        end
      end
    end
  end

  describe '#display_description' do
    let(:description_type_preferred_order) do
      %i( raw_footage_description segment_description clip_description
          promo_description episode_description program_description )
    end

    it 'returns the most preferred description type' do
      description_type_preferred_order.each do |desc_type|
        # Expect #display_desciption to be the same as the next preferred
        # description.
        expect(asset_solr_doc.display_description).to eq asset_solr_doc.send(desc_type).first
        # Now nilify the description type we just compared, and loop to assert
        # the next preferred description.
        allow(asset_solr_doc).to receive(desc_type).and_return(nil)
      end
    end
  end

  describe '#media_src' do
    let(:test_id) { 'cpb-aacip_600-fx73t9dc4n' }

    before do
      allow(solr_document).to receive(:id) { test_id }
    end

    context 'when a solr_document has an id' do
      it 'can return an expected media_src' do
        expect(solr_document.media_src(0.to_s)).to eq("/media/#{test_id}?part=0")
        expect(solr_document.media_src(0)).to eq("/media/#{test_id}?part=0")
      end
    end
  end

  describe '#digitized?' do
    it 'returns true if there are any sonci_id values' do
      allow(solr_document).to receive(:sonyci_id).and_return(['asdf'])
      expect(solr_document.digitized?).to eq true
    end

    it 'returns false if sonyci_id is nil' do
      allow(solr_document).to receive(:sonyci_id).and_return(nil)
      expect(solr_document.digitized?).to eq false
    end

    it 'returns false if sonyci_id is an empty array' do
      allow(solr_document).to receive(:sonyci_id).and_return([])
      expect(solr_document.digitized?).to eq false
    end
  end

  describe '#display_dates' do
    context 'when a solr doc has dates' do
      let(:expected_display_dates_sorted) {
        {
          "date_tesim" => asset.date.sort,
          "broadcast_date_tesim" => asset.broadcast_date.sort,
          "created_date_tesim" => asset.created_date.sort,
          "copyright_date_tesim" => asset.copyright_date.sort
        }
      }

      it 'returns a hash of dates' do
        display_dates_sorted = Hash[
          asset_solr_doc.display_dates.map do |date_field, dates|
            [date_field, dates.sort]
          end
        ]
        expect(display_dates_sorted).to eq expected_display_dates_sorted
      end
    end

    context 'when a solr doc does not have dates' do
      it 'returns an empty hash' do
        expect(solr_document.display_dates).to eq Hash.new
      end
    end
  end

  describe '#identifying_data' do
    let(:expected_id_data) {
      {
        "id" => asset_solr_doc.id,
        Solrizer.solr_name('admin_set') => asset_solr_doc.admin_set
      }
    }

    it 'returns the expected identifying data' do
      expect(asset_solr_doc.identifying_data).to eq expected_id_data
    end
  end

  describe "#all_members" do
    it 'returns all the IDs for DigitalInstantiations, PhysicalInstantiations, and EssenceTracks associated with an Asset' do
      expect(asset_solr_doc.all_members.map(&:id).to_set).to eq(asset.all_members.map(&:id).to_set)
    end
  end

  describe '#members' do
    context 'with > 10 members (i.e. the default row limit)' do
      let(:asset) {
        create(:asset, ordered_members: [
            # 11 members across 3 different types
            create_list(:contribution, 9),
            create(:digital_instantiation),
            create(:physical_instantiation)
        ].flatten)
      }

      let(:expected_member_ids) {[
        asset.contributions.map(&:id),
        asset.digital_instantiations.map(&:id),
        asset.physical_instantiations.map(&:id)
      ].flatten

      }

      it 'returns them all' do
        expect(asset_solr_doc.members.map(&:id).to_set).to eq expected_member_ids.to_set
      end
    end
  end

  describe '#intended_children_count' do
    let(:asset) { create(:asset, :with_physical_digital_and_essence_track, intended_children_count: '3') }

    it 'indexes as an Integer' do
      expect(asset_solr_doc.intended_children_count).to eq(asset.intended_children_count.to_i)
    end
  end

  describe '#validation_status_for_aapb' do
    let(:asset) { create(:asset, :with_physical_digital_and_essence_track, validation_status_for_aapb: ['test']) }

    it 'indexes the value as an Array' do
      # Use #to_a since asset.validation_status_for_aapb is an ActiveTriples::Relation, which causes the
      # test to fail when compared directly with asset_solr_doc.validation_status_for_aapb
      expect(asset_solr_doc.validation_status_for_aapb).to eq(asset.validation_status_for_aapb.to_a)
    end
  end
end
