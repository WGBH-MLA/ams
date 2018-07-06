# Generated via
#  `rails generate hyrax:work DigitalInstantiation`
require 'rails_helper'

RSpec.describe DigitalInstantiation do
  context "date" do
    let(:digital_instantiation) { FactoryBot.build(:digital_instantiation) }
    it "has date" do
      digital_instantiation.date = ["Test date"]
      expect(digital_instantiation.resource.dump(:ttl)).to match(/terms\/date/)
      expect(digital_instantiation.date.include?("Test date")).to be true
    end
  end

  context "dimensions" do
    let(:digital_instantiation) { FactoryBot.build(:digital_instantiation) }
    it "has dimensions" do
      digital_instantiation.dimensions = ["Test dimensions"]
      expect(digital_instantiation.resource.dump(:ttl)).to match(/ebucore#dimensions/)
      expect(digital_instantiation.dimensions.include?("Test dimensions")).to be true
    end
  end

  context "digital_format" do
    let(:digital_instantiation) { FactoryBot.build(:digital_instantiation) }
    it "has digital_format" do
      digital_instantiation.digital_format = "Test digital_format"
      expect(digital_instantiation.resource.dump(:ttl)).to match(/ebucore#hasFormat/)
      expect(digital_instantiation.digital_format.include?("Test digital_format")).to be true
    end
  end

  context "standard" do
    let(:digital_instantiation) { FactoryBot.build(:digital_instantiation) }
    it "has standard" do
      digital_instantiation.standard = ["Test standard"]
      expect(digital_instantiation.resource.dump(:ttl)).to match(/ebucore#hasStandard/)
      expect(digital_instantiation.standard.include?("Test standard")).to be true
    end
  end

  context "location" do
    let(:digital_instantiation) { FactoryBot.build(:digital_instantiation) }
    it "has location" do
      digital_instantiation.location = "Test location"
      expect(digital_instantiation.resource.dump(:ttl)).to match(/ebucore#locator/)
      expect(digital_instantiation.location.include?("Test location")).to be true
    end
  end

  context "media_type" do
    let(:digital_instantiation) { FactoryBot.build(:digital_instantiation) }
    it "has media_type" do
      digital_instantiation.media_type = "Test media_type"
      expect(digital_instantiation.resource.dump(:ttl)).to match(/terms\/type/)
      expect(digital_instantiation.media_type.include?("Test media_type")).to be true
    end
  end

  context "generations" do
    let(:digital_instantiation) { FactoryBot.build(:digital_instantiation) }
    it "has generations" do
      digital_instantiation.generations = ["Test generations"]
      expect(digital_instantiation.resource.dump(:ttl)).to match(/ebucore#hasGeneration/)
      expect(digital_instantiation.generations.include?("Test generations")).to be true
    end
  end

  context "file_size" do
    let(:digital_instantiation) { FactoryBot.build(:digital_instantiation) }
    it "has file_size" do
      digital_instantiation.file_size = "Test file_size"
      expect(digital_instantiation.resource.dump(:ttl)).to match(/ebucore#fileSize/)
      expect(digital_instantiation.file_size.include?("Test file_size")).to be true
    end
  end

  context "time_start" do
    let(:digital_instantiation) { FactoryBot.build(:digital_instantiation) }
    it "has time_start" do
      digital_instantiation.time_start = "Test time_start"
      expect(digital_instantiation.resource.dump(:ttl)).to match(/ebucore#start/)
      expect(digital_instantiation.time_start.include?("Test time_start")).to be true
    end
  end

  context "duration" do
    let(:digital_instantiation) { FactoryBot.build(:digital_instantiation) }
    it "has duration" do
      digital_instantiation.duration = "Test duration"
      expect(digital_instantiation.resource.dump(:ttl)).to match(/ebucore#duration/)
      expect(digital_instantiation.duration.include?("Test duration")).to be true
    end
  end

  context "data_rate" do
    let(:digital_instantiation) { FactoryBot.build(:digital_instantiation) }
    it "has data_rate" do
      digital_instantiation.data_rate = "Test data_rate"
      expect(digital_instantiation.resource.dump(:ttl)).to match(/ebucore#bitRate/)
      expect(digital_instantiation.data_rate.include?("Test data_rate")).to be true
    end
  end

  context "colors" do
    let(:digital_instantiation) { FactoryBot.build(:digital_instantiation) }
    it "has colors" do
      digital_instantiation.colors = "Test colors"
      expect(digital_instantiation.resource.dump(:ttl)).to match(/bibframe.html#c_ColorContent/)
      expect(digital_instantiation.colors.include?("Test colors")).to be true
    end
  end

  context "rights_summary" do
    let(:digital_instantiation) { FactoryBot.build(:digital_instantiation) }
    it "has rights_summary" do
      digital_instantiation.rights_summary = ["Test rights_summary"]
      expect(digital_instantiation.resource.dump(:ttl)).to match(/elements\/1.1\/rights/)
      expect(digital_instantiation.rights_summary.include?("Test rights_summary")).to be true
    end
  end

  context "rights_link" do
    let(:digital_instantiation) { FactoryBot.build(:digital_instantiation) }
    it "has rights_link" do
      digital_instantiation.rights_link = ["Test rights_link"]
      expect(digital_instantiation.resource.dump(:ttl)).to match(/europeana.eu\/rights/)
      expect(digital_instantiation.rights_link.include?("Test rights_link")).to be true
    end
  end

  context "annotation" do
    let(:digital_instantiation) { FactoryBot.build(:digital_instantiation) }
    it "has annotation" do
      digital_instantiation.annotation = ["Test annotation"]
      expect(digital_instantiation.resource.dump(:ttl)).to match(/02\/skos\/core#note/)
      expect(digital_instantiation.annotation.include?("Test annotation")).to be true
    end
  end

  context "local_instantiation_identifer" do
    let(:digital_instantiation) { FactoryBot.build(:digital_instantiation) }
    it "has local_instantiation_identifer" do
      digital_instantiation.local_instantiation_identifer = ["Test local_instantiation_identifer"]
      expect(digital_instantiation.resource.dump(:ttl)).to match(/pbcore.org#localInstantiationIdentifie/)
      expect(digital_instantiation.local_instantiation_identifer.include?("Test local_instantiation_identifer")).to be true
    end
  end

  context "tracks" do
    let(:digital_instantiation) { FactoryBot.build(:digital_instantiation) }
    it "has tracks" do
      digital_instantiation.tracks = "Test tracks"
      expect(digital_instantiation.resource.dump(:ttl)).to match(/pbcore.org#hasTracks/)
      expect(digital_instantiation.tracks.include?("Test tracks")).to be true
    end
  end

  context "channel_configuration" do
    let(:digital_instantiation) { FactoryBot.build(:digital_instantiation) }
    it "has channel_configuration" do
      digital_instantiation.channel_configuration = "Test channel_configuration"
      expect(digital_instantiation.resource.dump(:ttl)).to match(/pbcore.org#hasChannelConfiguration/)
      expect(digital_instantiation.channel_configuration.include?("Test channel_configuration")).to be true
    end
  end

  context "alternative_modes" do
    let(:digital_instantiation) { FactoryBot.build(:digital_instantiation) }
    it "has alternative_modes" do
      digital_instantiation.alternative_modes = ["Test alternative_modes"]
      expect(digital_instantiation.resource.dump(:ttl)).to match(/pbcore.org#hasAlternativeModes/)
      expect(digital_instantiation.alternative_modes.include?("Test alternative_modes")).to be true
    end
  end

  context "holding_organization" do
    let(:digital_instantiation) { FactoryBot.build(:digital_instantiation) }
    it "has holding_organization" do
      digital_instantiation.holding_organization = "Test holding_organization"
      expect(digital_instantiation.resource.dump(:ttl)).to match(/pbcore.org#hasHoldingOrganization/)
      expect(digital_instantiation.holding_organization.include?("Test holding_organization")).to be true
    end
  end
end
