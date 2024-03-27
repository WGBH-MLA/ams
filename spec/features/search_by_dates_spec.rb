require 'rails_helper'

RSpec.describe 'Search by dates', reset_data: false, js: true, skip: true do

  def various_dates
    @various_dates ||= %w(
      2008 2008-08 2008-08-08
      2009
      2010 2010-10 2010-10-10
    )
  end

  # TODO: Get this from controlled vocab?
  def date_fields
    [:date, :broadcast_date, :created_date, :copyright_date]
  end

  def assets
    @assets ||= various_dates.each_with_index.map do |date, index|
      # Use one of the date fields, cycling through them. We want them all to
      # be used in the date range queries. Cycling is better than random though.
      date_field = date_fields[ index % date_fields.count ]

      # Merge the date attribute with a hash of empty date attributes so we
      # don't have any default values coming from the Asset factory to alter
      # our search results.
      empty_date_attrs = { date: nil, broadcast_date: nil, copyright_date: nil, created_date: nil }

      # Create the asset with the date value (cast to an Array because they are
      # all multi-valued), and return the new Asset from the block to add it to
      # the @assets array for use in tests below.
      create( :asset, empty_date_attrs.merge( { date_field => Array(date) } ) )
    end
  end

  # Return all assets with at least one of date field having at least one of the
  # supplied dates.
  def assets_with_dates(*dates)
    assets.select do |asset|
      date_fields.any? do |date_field|
        dates.any? do |date|
          asset.send(date_field).include? date
        end
      end
    end
  end

  # Before all examples, cache the test Assets
  before(:all) { assets }

  context "with exact YYYY" do
    before { search_by_date(exact: '2008') }
    it 'returns all assets with at least one date within that year' do
      expect(page).to only_have_search_results assets_with_dates( '2008',
                                                                  '2008-08',
                                                                  '2008-08-08' )
    end
  end

  context "with exact YYYY-MM" do
    before { search_by_date(exact: '2008-08') }
    it 'returns all assets with at least one date for that year and month' do
      expect(page).to only_have_search_results assets_with_dates( '2008-08',
                                                                  '2008-08-08' )
    end
  end

  context "Exact YYYY-MM-DD" do
    before { search_by_date(exact: '2008-08-08') }
    it 'returns all assets with a date on that exact day' do
      expect(page).to only_have_search_results assets_with_dates( '2008-08-08' )
    end
  end

  context "Range YYYY TO *" do
    before { search_by_date(after: '2010') }
    it 'returns all assets with a date after the first day of the specified year' do
      expect(page).to only_have_search_results assets_with_dates( '2010-10-10',
                                                                  '2010-10',
                                                                  '2010' )
    end
  end

  context "Range YYYY-MM TO *" do
    before { search_by_date(after: '2010-10') }
    it 'returns all assets with a date after the first of the specified year and month' do
      expect(page).to only_have_search_results assets_with_dates( '2010-10',
                                                                  '2010-10-10' )
    end
  end

  context "Range YYYY-MM-DD TO *" do
    before { search_by_date(after: '2010-10-10') }
    it 'returns all assets with a date after the first of the specified year and month' do
      expect(page).to only_have_search_results assets_with_dates( '2010-10-10' )
    end
  end

  context "Range * TO YYYY" do
    before { search_by_date(before: '2008') }
    it 'returns all assets with a date on or before the last day of the specified year' do
      expect(page).to only_have_search_results assets_with_dates( '2008',
                                                                  '2008-08',
                                                                  '2008-08-08' )
    end
  end

  context "Range * TO YYYY-MM" do
    before { search_by_date(before: '2008-08') }
    it 'returns all assets with a date on or before the last day of the specified year and month' do
      expect(page).to only_have_search_results assets_with_dates( '2008-08',
                                                                  '2008-08-08' )
    end
  end

  context "Range * TO YYYY-MM-DD" do
    before { search_by_date(before: '2008-08-08') }
    it 'returns all assets with a date on or before the last day of the specified year and month' do
      expect(page).to only_have_search_results assets_with_dates( '2008-08-08' )
    end
  end

  context "Range YYYY TO YYYY" do
    before { search_by_date(after: '2009', before: '2010') }
    it 'returns all assets with a date on or after the first day of the earlier year, and on or before the last day of the later year' do
      expect(page).to only_have_search_results assets_with_dates( '2009',
                                                                  '2010',
                                                                  '2010-10',
                                                                  '2010-10-10' )
    end
  end

  context "Range YYYY TO YYYY-MM" do
    before { search_by_date(after: '2009', before: '2010-10') }
    it 'returns all assets with a date on or after the first day of the ' \
       'earlier year, and on or before the last day of the later year/month' do
      expect(page).to only_have_search_results assets_with_dates( '2009',
                                                                  '2010-10',
                                                                  '2010-10-10' )
    end
  end

  context "Range YYYY TO YYYY-MM-DD" do
    before { search_by_date( after: '2009', before: '2010-10-10' ) }
    it 'returns all assets with a date on or after the first day of the ' \
       'earlier year, and on or before the last year/month/day' do
      expect(page).to only_have_search_results assets_with_dates( '2009',
                                                                  '2010-10-10' )
    end
  end

  context "Range YYYY-MM TO YYYY" do
    before { search_by_date( after: '2008-08', before: '2010' ) }
    it 'returns all assets with a date on or after the first day of the ' \
       'earlier year/month, and on or before the last day of the later year' do
      expect(page).to only_have_search_results assets_with_dates( '2008-08',
                                                                  '2008-08-08',
                                                                  '2009',
                                                                  '2010',
                                                                  '2010-10',
                                                                  '2010-10-10' )
    end
  end

  context "Range YYYY-MM TO YYYY-MM" do
    before { search_by_date( after: '2008-08', before: '2010-10' ) }
    it 'returns all assets with a date on or after the first day of the ' \
       'earlier year/month, and on or before the last day of the later ' \
       'year/month' do
      expect(page).to only_have_search_results assets_with_dates( '2008-08',
                                                                  '2008-08-08',
                                                                  '2009',
                                                                  '2010-10',
                                                                  '2010-10-10' )
    end
  end

  context "Range YYYY-MM TO YYYY-MM-DD" do
    before { search_by_date( after: '2008-08', before: '2010-10-10' ) }
    it 'returns all assets with a date on or after the first day of the ' \
       'earlier year/month, and on or before the later year/month/day' do
      expect(page).to only_have_search_results assets_with_dates( '2008-08',
                                                                  '2008-08-08',
                                                                  '2009',
                                                                  '2010-10-10' )
    end
  end

  context "Range YYYY-MM-DD TO YYYY" do
    before { search_by_date( after: '2008-08-08', before: '2010' ) }
    it 'returns all assets with a date on or after the first year/month/day ' \
       'and on or before the last day of the later year' do
      expect(page).to only_have_search_results assets_with_dates( '2008-08-08',
                                                                  '2009',
                                                                  '2010',
                                                                  '2010-10',
                                                                  '2010-10-10' )
    end
  end

  context "Range YYYY-MM-DD TO YYYY-MM" do
    before { search_by_date( after: '2008-08-08', before: '2010-10' ) }
    it 'returns all assets with a date on or after the first year/month/day ' \
       'and on or before the last day of the later year/month' do
      expect(page).to only_have_search_results assets_with_dates( '2008-08-08',
                                                                  '2009',
                                                                  '2010-10',
                                                                  '2010-10-10' )
    end
  end

  context "Range YYYY-MM-DD TO YYYY-MM-DD" do
    before { search_by_date( after: '2008-08-08', before: '2010-10-10' ) }
    it 'returns all assets with a date on or after the first year/month/day ' \
       'and on or before the later year/month/day' do
      expect(page).to only_have_search_results assets_with_dates( '2008-08-08',
                                                                  '2009',
                                                                  '2010-10-10' )
    end
  end
end
