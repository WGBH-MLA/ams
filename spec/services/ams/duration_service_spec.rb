require 'rails_helper'

RSpec.describe AMS::TimeCodeService do
  let(:regex) { AMS::TimeCodeService.regex }

  describe '.regex_for_html' do
    let(:regex_for_html) { AMS::TimeCodeService.regex_for_html }

    it 'returns the string equivalent of the regular expression for use in HTML5 pattern attribute' do
      expect(Regexp.new(regex_for_html)).to eq regex
    end

    it 'is not the same things as calling #regex_string (which is invalid syntax for HTML5 pattern attribute)' do
      expect(regex_for_html).to_not eq regex_string
    end
  end

  describe 'regex' do
    def valid_formats
      @valid_formats ||= %w(
        1:23
        1:23.4
        1:23.45
        1:23.456
        12:34
        12:34.5
        12:34.56
        12:34.567
        1:23:45
        1:23:45.6
        1:23:45.67
        1:23:45.678
        12:34:56
        12:34:56.7
        12:34:56.78
        12:34:56.789
        123:45:67
        123:45:67.8
        123:45:67.89
        123:45:67.890
      )
    end

    def invalid_formats
      @invalid_formats ||= %w(
        1
        12
        12.3
        12.34
        12.345
        1:2
        1:2.3
        1:2.34
        1:2.345
        12:3
        12:3.4
        12:3.45
        12:3.456
        1:23:4
        1:23:4.5
        1:23:4.56
        1:23:4.567
        1:2:34
        1:2:34.5
        1:2:34.56
        1:2:34.567
        :1
        :12
        :12.3
        :12.34
        :12.345
        :12:34
        :12:34.5
        :12:34.56
        :12:34.567
        :2:34
        :2:34.5
        :2:34.56
        :2:34.567
      )
    end

    it 'returns a Regexp object' do
      expect(regex).to be_a Regexp
    end

    it 'matches variations on the HH::MM:SS.SSS format for a time duration' do
      valid_formats.each do |valid_format|
        expect(valid_format).to match regex
      end
    end

    it 'does not match invalid variations on duration' do
      invalid_formats.each do |invalid_format|
        expect(invalid_format).to_not match regex
      end
    end
  end
end
