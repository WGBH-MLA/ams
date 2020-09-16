require 'rails_helper'

RSpec.describe ApplicationHelper do
  describe '#display_date' do

    it 'can reformat mm/dd/yyyy to yyyy-mm-dd' do
      expect(helper.display_date('01/16/2014', from_format: '%m/%d/%Y')).to eq '2014-01-16'
    end

    it 'can output a custom date format' do
      expect(helper.display_date('2014-01-16', format: '%Y hello %m world %d', from_format: '%Y-%m-%d')).to eq '2014 hello 01 world 16'
    end

    it 'eats bad dates, returns nil' do
      expect(helper.display_date('bad date')).to eq nil
    end

    it 'can convert a timestamp to a readable EDT date time' do
      # Create an arbitrary date (during daylight savings) and make it a timestamp.
      timestamp = Time.new(2020, 9, 15, 5, 10, 15, "+00:00").strftime('%s')
      # Format a pretty date from the timestamp AND change the timezone.
      display_date = helper.display_date(timestamp, format: '%Y-%m-%d %H:%M:%S %Z',
                                                    from_format: '%s',
                                                    time_zone: 'US/Eastern')

      # Expect the EDT time to be 4 hours earlier (i.e. Eastern time during
      # daylight savings).
      expect(display_date).to eq '2020-09-15 01:10:15 EDT'
    end
  end
end
