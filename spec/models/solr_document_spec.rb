require 'rails_helper'

describe SolrDocument do
  let(:solr_document) { described_class.new }
  let(:asset) { create(:asset) }

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
    # These descriptions are in the order of preference of the display_description method
    # which we are using for the convenience of using an index in the tests below.
    let(:all_description_types) do {
          raw_footage_description: ['Raw Footage Description'],
          segment_description: ['Segment Description'],
          clip_description: ['Clip Description'],
          promo_description: ['Promo Description'],
          episode_description: ['Episode Description'],
          program_description: ['Program Description']
      }
    end

    context 'when all descriptions are available' do
      before do
         all_description_types.each { |k,v| allow(solr_document).to receive(k).and_return(v) }
      end
      it 'returns the raw_footage_description' do
        expect(solr_document.display_description).to eq(all_description_types[:raw_footage_description].first)
      end
    end

    context 'when different descriptions are available' do
      def build_description_types(index)
        all_description_types.each_with_index { | (k,v),i | all_description_types[k] = nil if i <= index }
      end

      it 'chooses the right description' do
        (0..(all_description_types.length - 2)).each do |index|
          descriptions = build_description_types(index)
          key = descriptions.keys[index + 1]
          descriptions.each { |k,v| allow(solr_document).to receive(k).and_return(v) }
          expect(solr_document.display_description).to eq(descriptions[key].first)
        end
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
      let(:asset_solr_doc) { SolrDocument.find(asset.id) }
      let(:expected_dates) {
        {
          "date_tesim" => ["2010","2015-01","1987-10-31"],
          "broadcast_date_tesim" => ["2010","2015-01","1987-10-31"],
          "created_date_tesim" => ["2010","2015-01","1987-10-31"],
          "copyright_date_tesim" => ["2010","2015-01","1987-10-31"]
        }
      }
      it 'returns a hash of dates' do
        expect(asset_solr_doc.display_dates.map{ |k,v| v.sort }).to eq expected_dates.map{ |k,v| v.sort }
        expect(asset_solr_doc.display_dates.keys.sort).to eq expected_dates.keys.sort
      end
    end

    context 'when a solr doc does not have dates' do
      it 'returns an empty hash' do
        expect(solr_document.display_dates).to eq Hash.new
      end
    end
  end

  describe '#identifying_data' do
    let(:asset_solr_doc) { SolrDocument.find(asset.id) }
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
end
