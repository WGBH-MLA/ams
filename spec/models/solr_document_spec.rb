require 'rails_helper'

describe SolrDocument do
  let(:solr_document) { described_class.new }
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
end
