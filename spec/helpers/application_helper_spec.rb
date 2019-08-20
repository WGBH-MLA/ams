require 'rails_helper'

RSpec.describe ApplicationHelper do
  describe '#display_date' do

    it 'can reformat mm/dd/yyyy to yyyy-mm-dd' do
      expect(helper.display_date('01/16/2014', from_format: '%m/%d/%Y')).to eq '2014-01-16'
    end

    it 'can output a custom date format' do
      expect(helper.display_date('2014-01-16', format: '%Y hello %m world %d')).to eq '2014 hello 01 world 16'
    end

    it 'eats bad dates, returns nil' do
      expect(helper.display_date('bad date')).to eq nil
    end
  end
end
