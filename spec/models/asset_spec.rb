# Generated via
#  `rails generate hyrax:work Asset`
require 'rails_helper'

RSpec.describe Asset do
  let(:asset) { build(:asset) }

  describe "#title" do
    it "returns the title" do
      asset.title = ["Test title 1","Test title 2"]
      expect(asset.resource.dump(:ttl)).to match(/terms\/title/)
      expect(asset.title.include?("Test title 1")).to be true
    end
  end

  describe "#asset_types" do
    it "returns the asset_types" do
      asset.asset_types = ["Clip","Album"]
      expect(asset.resource.dump(:ttl)).to match(/ebucore\/ebucore#hasType/)
      expect(asset.asset_types.include?("Clip")).to be true
    end
  end

  describe "#genre" do
    it "returns the genre" do
      asset.genre = ["Debate","Documentary"]
      expect(asset.resource.dump(:ttl)).to match(/ebucore\/ebucore#hasGenre/)
      expect(asset.genre.include?("Debate")).to be true
    end
  end

  describe "#date" do
    it "returns the date" do
      asset.date = ["02-11-2001"]
      expect(asset.resource.dump(:ttl)).to match(/terms\/date/)
      expect(asset.date.include?("02-11-2001")).to be true
    end
  end

  describe "#broadcast_date" do
    it "returns the broadcast_date" do
      asset.broadcast_date = ["02-11-2002"]
      expect(asset.resource.dump(:ttl)).to match(/pbcore.org#hasBroadcastDate/)
      expect(asset.broadcast_date.include?("02-11-2002")).to be true
    end
  end

  describe "#created_date" do
    it "returns the created_date" do
      asset.created_date = ["03-11-2001"]
      expect(asset.resource.dump(:ttl)).to match(/pbcore.org#hasCreatedDate/)
      expect(asset.created_date.include?("03-11-2001")).to be true
    end
  end

  describe "#copyright_date" do
    it "returns the copyright_date" do
      asset.copyright_date = ["03-09-2001"]
      expect(asset.resource.dump(:ttl)).to match(/pbcore.org#hasCopyrightDate/)
      expect(asset.copyright_date.include?("03-09-2001")).to be true
    end
  end

  describe "#episode_number" do
    it "returns the episode_number" do
      asset.episode_number = ["SSPE12"]
      expect(asset.resource.dump(:ttl)).to match(/ebucore\/ebucore#episodeNumber/)
      expect(asset.episode_number.include?("SSPE12")).to be true
    end
  end

  describe "#spatial_coverage" do
    it "returns the spatial_coverage" do
      asset.spatial_coverage = ["Test Coverage"]
      expect(asset.resource.dump(:ttl)).to match(/terms\/coverage/)
      expect(asset.spatial_coverage.include?("Test Coverage")).to be true
    end
  end

  describe "#temporal_coverage" do
    it "returns the temporal_coverage" do
      asset.temporal_coverage = ["Test temporal Coverage"]
      expect(asset.resource.dump(:ttl)).to match(/bibframe.html#p_temporalCoverage/)
      expect(asset.temporal_coverage.include?("Test temporal Coverage")).to be true
    end
  end

  describe "#audience_level" do
    it "returns the audience_level" do
      asset.audience_level = ["Test audience_level"]
      expect(asset.resource.dump(:ttl)).to match(/ebucore\/ebucore#hasTargetAudience/)
      expect(asset.audience_level.include?("Test audience_level")).to be true
    end
  end

  describe "#audience_rating" do
    it "returns the audience_rating" do
      asset.audience_rating = ["Test Rating"]
      expect(asset.resource.dump(:ttl)).to match(/ebucore\/index.html#Type/)
      expect(asset.audience_rating.include?("Test Rating")).to be true
    end
  end

  describe "#annotation" do
    it "returns the annotation" do
      asset.annotation = ["Test annotation"]
      expect(asset.resource.dump(:ttl)).to match(/skos\/core#note/)
      expect(asset.annotation.include?("Test annotation")).to be true
    end
  end

  describe "#rights_summary" do
    it "returns the rights_summary" do
      asset.rights_summary = ["Test rights_summary"]
      expect(asset.resource.dump(:ttl)).to match(/elements\/1.1\/rights/)
      expect(asset.rights_summary.include?("Test rights_summary")).to be true
    end
  end

  describe "#rights_link" do
    it "returns the rights_link" do
      asset.rights_link = ["Test rights_link"]
      expect(asset.resource.dump(:ttl)).to match(/europeana.eu\/rights/)
      expect(asset.rights_link.include?("Test rights_link")).to be true
    end
  end

  describe "#local_identifier" do
    it "returns the local_identifier" do
      asset.local_identifier = ["Test local_identifier"]
      expect(asset.resource.dump(:ttl)).to match(/identifiers\/local/)
      expect(asset.local_identifier.include?("Test local_identifier")).to be true
    end
  end

  describe "#pbs_nola_code" do
    it "returns the pbs_nola_code" do
      asset.pbs_nola_code = ["Test pbs_nola_code"]
      expect(asset.resource.dump(:ttl)).to match(/bibframe.html\#p_code/)
      expect(asset.pbs_nola_code.include?("Test pbs_nola_code")).to be true
    end
  end

  describe "#eidr_id" do
    it "returns the eidr_id" do
      asset.eidr_id = ["Test eidr_id"]
      expect(asset.resource.dump(:ttl)).to match(/2002\/07\/owl#sameAs/)
      expect(asset.eidr_id.include?("Test eidr_id")).to be true
    end
  end

  describe "#topics" do
    it "returns the topics" do
      asset.topics = ["Test topics"]
      expect(asset.resource.dump(:ttl)).to match(/ebucore\/ebucore#hasKeyword/)
      expect(asset.topics.include?("Test topics")).to be true
    end
  end

  describe "#subject" do
    it "returns the subject" do
      asset.subject = ["Test subject"]
      expect(asset.resource.dump(:ttl)).to match(/elements\/1.1\/subject/)
      expect(asset.subject.include?("Test subject")).to be true
    end
  end

  describe "#program_title" do
    it "returns the program_title" do
      asset.program_title = ["Test program_title"]
      expect(asset.resource.dump(:ttl)).to match(/pbcore.org#hasProgramTitle/)
      expect(asset.program_title.include?("Test program_title")).to be true
    end
  end

  describe "#episode_title" do
    it "returns the episode_title" do
      asset.episode_title = ["Test episode_title"]
      expect(asset.resource.dump(:ttl)).to match(/pbcore.org#hasEpisodeTitle/)
      expect(asset.episode_title.include?("Test episode_title")).to be true
    end
  end

  describe "#segment_title" do
    it "returns the segment_title" do
      asset.segment_title = ["Test segment_title"]
      expect(asset.resource.dump(:ttl)).to match(/pbcore.org#hasSegmentTitle/)
      expect(asset.segment_title.include?("Test segment_title")).to be true
    end
  end

  describe "#raw_footage_title" do
    it "returns the raw_footage_title" do
      asset.raw_footage_title = ["Test raw_footage_title"]
      expect(asset.resource.dump(:ttl)).to match(/pbcore.org#hasRawFootageTitle/)
      expect(asset.raw_footage_title.include?("Test raw_footage_title")).to be true
    end
  end

  describe "#promo_title" do
    it "returns the promo_title" do
      asset.promo_title = ["Test promo_title"]
      expect(asset.resource.dump(:ttl)).to match(/pbcore.org#hasPromoTitle/)
      expect(asset.promo_title.include?("Test promo_title")).to be true
    end
  end

  describe "#clip_title" do
    it "returns the clip_title" do
      asset.clip_title = ["Test clip_title"]
      expect(asset.resource.dump(:ttl)).to match(/pbcore.org#hasClipTitle/)
      expect(asset.clip_title.include?("Test clip_title")).to be true
    end
  end

  describe "#program_description" do
    it "returns the program_description" do
      asset.program_description = ["Test program_description"]
      expect(asset.resource.dump(:ttl)).to match(/pbcore.org#hasProgramDescription/)
      expect(asset.program_description.include?("Test program_description")).to be true
    end
  end

  describe "#episode_description" do
    it "returns the episode_description" do
      asset.episode_description = ["Test episode_description"]
      expect(asset.resource.dump(:ttl)).to match(/pbcore.org#hasEpisodeDescription/)
      expect(asset.episode_description.include?("Test episode_description")).to be true
    end
  end

  describe "#segment_description" do
    it "returns the segment_description" do
      asset.segment_description = ["Test segment_description"]
      expect(asset.resource.dump(:ttl)).to match(/pbcore.org#hasSegmentDescription/)
      expect(asset.segment_description.include?("Test segment_description")).to be true
    end
  end

  describe "#raw_footage_description" do
    it "returns the raw_footage_description" do
      asset.raw_footage_description = ["Test raw_footage_description"]
      expect(asset.resource.dump(:ttl)).to match(/pbcore.org#hasRawFootageDescription/)
      expect(asset.raw_footage_description.include?("Test raw_footage_description")).to be true
    end
  end

  describe "#promo_description" do
    it "returns the promo_description" do
      asset.promo_description = ["Test promo_description"]
      expect(asset.resource.dump(:ttl)).to match(/pbcore.org#hasPromoDescription/)
      expect(asset.promo_description.include?("Test promo_description")).to be true
    end
  end

  describe "#clip_description" do
    it "returns the clip_description" do
      asset.clip_description = ["Test clip_description"]
      expect(asset.resource.dump(:ttl)).to match(/pbcore.org#hasClipDescription/)
      expect(asset.clip_description.include?("Test clip_description")).to be true
    end
  end


end
