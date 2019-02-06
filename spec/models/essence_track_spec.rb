# Generated via
#  `rails generate hyrax:work Asset`
require 'rails_helper'

RSpec.describe EssenceTrack do

  context "title" do
    let(:contribution) { FactoryBot.build(:contribution) }
    it "has title" do
      contribution.title = ["Test title 1","Test title 2"]
      expect(contribution.resource.dump(:ttl)).to match(/terms\/title/)
      expect(contribution.title.include?("Test title 1")).to be true
    end
  end

  context "track_type" do
    let(:essence_track) { FactoryBot.build(:essence_track) }
    it "has track_type" do
      essence_track.track_type = "Test track_type"
      expect(essence_track.resource.dump(:ttl)).to match(/ebucore#trackType/)
      expect(essence_track.track_type.include?("Test track_type")).to be true
    end
  end

  context "track_id" do
    let(:essence_track) { FactoryBot.build(:essence_track) }
    it "has track_id" do
      essence_track.track_id = ["Test track_id"]
      expect(essence_track.resource.dump(:ttl)).to match(/ebucore#trackName/)
      expect(essence_track.track_id.include?("Test track_id")).to be true
    end
  end

  context "standard" do
    let(:essence_track) { FactoryBot.build(:essence_track) }
    it "has standard" do
      essence_track.standard = "Test standard"
      expect(essence_track.resource.dump(:ttl)).to match(/ebucore#hasStandard/)
      expect(essence_track.standard.include?("Test standard")).to be true
    end
  end

  context "encoding" do
    let(:essence_track) { FactoryBot.build(:essence_track) }
    it "has encoding" do
      essence_track.encoding = "Test encoding"
      expect(essence_track.resource.dump(:ttl)).to match(/ebucore#hasEncodingFormat/)
      expect(essence_track.encoding.include?("Test encoding")).to be true
    end
  end

  context "data_rate" do
    let(:essence_track) { FactoryBot.build(:essence_track) }
    it "has data_rate" do
      essence_track.data_rate = "Test data_rate"
      expect(essence_track.resource.dump(:ttl)).to match(/ebucore#bitRate/)
      expect(essence_track.data_rate.include?("Test data_rate")).to be true
    end
  end

  context "frame_rate" do
    let(:essence_track) { FactoryBot.build(:essence_track) }
    it "has frame_rate" do
      essence_track.frame_rate = "Test frame_rate"
      expect(essence_track.resource.dump(:ttl)).to match(/ebucore#frameRate/)
      expect(essence_track.frame_rate.include?("Test frame_rate")).to be true
    end
  end

  context "playback_speed" do
    let(:essence_track) { FactoryBot.build(:essence_track) }
    it "has playback_speed" do
      essence_track.playback_speed = "24"
      expect(essence_track.resource.dump(:ttl)).to match(/ebucore#playbackSpeed/)
      expect(essence_track.playback_speed).to eq "24"
    end
  end

  context "playback_speed_units" do
    let(:essence_track) { FactoryBot.build(:essence_track) }
    it "has playback_speed_units" do
      essence_track.playback_speed_units = "fps"
      expect(essence_track.resource.dump(:ttl)).to match(/pbcore\.org#hasPlaybackSpeedUnits/)
      expect(essence_track.playback_speed_units).to eq "fps"
    end
  end

  context "sample_rate" do
    let(:essence_track) { FactoryBot.build(:essence_track) }
    it "has sample_rate" do
      essence_track.sample_rate = "Test sample_rate"
      expect(essence_track.resource.dump(:ttl)).to match(/ebucore#sampleRate/)
      expect(essence_track.sample_rate.include?("Test sample_rate")).to be true
    end
  end

  context "bit_depth" do
    let(:essence_track) { FactoryBot.build(:essence_track) }
    it "has bit_depth" do
      essence_track.bit_depth = "Test bit_depth"
      expect(essence_track.resource.dump(:ttl)).to match(/ebucore#bitDepth/)
      expect(essence_track.bit_depth.include?("Test bit_depth")).to be true
    end
  end

  context "frame_width" do
    let(:essence_track) { FactoryBot.build(:essence_track) }
    it "has frame_width" do
      essence_track.frame_width = "Test frame_width"
      expect(essence_track.resource.dump(:ttl)).to match(/ebucore#frameWidth/)
      expect(essence_track.frame_width.include?("Test frame_width")).to be true
    end
  end

  context "frame_height" do
    let(:essence_track) { FactoryBot.build(:essence_track) }
    it "has frame_height" do
      essence_track.frame_height = "Test frame_height"
      expect(essence_track.resource.dump(:ttl)).to match(/ebucore#frameHeight/)
      expect(essence_track.frame_height.include?("Test frame_height")).to be true
    end
  end

  context "aspect_ratio" do
    let(:essence_track) { FactoryBot.build(:essence_track) }
    it "has aspect_ratio" do
      essence_track.aspect_ratio = ["Test aspect_ratio"]
      expect(essence_track.resource.dump(:ttl)).to match(/ebucore#aspectRatio/)
      expect(essence_track.aspect_ratio.include?("Test aspect_ratio")).to be true
    end
  end

  context "time_start" do
    let(:essence_track) { FactoryBot.build(:essence_track) }
    it "has time_start" do
      essence_track.time_start = "Test time_start"
      expect(essence_track.resource.dump(:ttl)).to match(/ebucore#start/)
      expect(essence_track.time_start.include?("Test time_start")).to be true
    end
  end

  context "duration" do
    let(:essence_track) { FactoryBot.build(:essence_track) }
    it "has duration" do
      essence_track.duration = "Test duration"
      expect(essence_track.resource.dump(:ttl)).to match(/ebucore#duration/)
      expect(essence_track.duration.include?("Test duration")).to be true
    end
  end

  context "annotation" do
    let(:essence_track) { FactoryBot.build(:essence_track) }
    it "has annotation" do
      essence_track.annotation = ["Test annotation"]
      expect(essence_track.resource.dump(:ttl)).to match(/skos\/core#note/)
      expect(essence_track.annotation.include?("Test annotation")).to be true
    end
  end

end
