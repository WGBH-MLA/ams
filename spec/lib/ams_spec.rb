require 'rails_helper'

describe 'AMS' do
  describe '.reset_data!', reset_data: true do
    it 'results in a default "aapb-admin" user role' do
      expect(Role.find_by(name: 'aapb-admin')).to_not eq nil
    end
  end
end
