# Generated via
#  `rails generate hyrax:work Asset`
require 'rails_helper'

RSpec.describe EssenceTrack do
  subject { build(:essence_track) }

  it { is_expected.to have_property(:track_type) }
  it { is_expected.to have_property(:track_id) }
  it { is_expected.to have_property(:standard) }
  it { is_expected.to have_property(:encoding) }
  it { is_expected.to have_property(:data_rate) }
  it { is_expected.to have_property(:frame_rate) }
  it { is_expected.to have_property(:playback_speed) }
  it { is_expected.to have_property(:playback_speed_units) }
  it { is_expected.to have_property(:sample_rate) }
  it { is_expected.to have_property(:bit_depth) }
  it { is_expected.to have_property(:frame_width) }
  it { is_expected.to have_property(:frame_height) }
  it { is_expected.to have_property(:aspect_ratio) }
  it { is_expected.to have_property(:time_start) }
  it { is_expected.to have_property(:duration) }
  it { is_expected.to have_property(:annotation) }
end
