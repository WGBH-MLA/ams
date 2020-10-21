# Generated via
#  `rails generate hyrax:work PhysicalInstantiation`
require 'rails_helper'

RSpec.describe PhysicalInstantiation do
  context "date" do
    let(:physical_instantiation) { FactoryBot.build(:physical_instantiation) }
    it "has date" do
      physical_instantiation.date = ["Test date"]
      expect(physical_instantiation.resource.dump(:ttl)).to match(/terms\/date/)
      expect(physical_instantiation.date.include?("Test date")).to be true
    end
  end

  context "digitization_date" do
    let(:physical_instantiation) { FactoryBot.build(:physical_instantiation) }
    it "has digitization_date" do
      physical_instantiation.digitization_date = "Dec, 2011"
      expect(physical_instantiation.resource.dump(:ttl)).to match(/ebucore\/ebucore#dateDigitised/)
      expect(physical_instantiation.digitization_date.include?("Dec, 2011")).to be true
    end
  end

  context "dimensions" do
    let(:physical_instantiation) { FactoryBot.build(:physical_instantiation) }
    it "has dimensions" do
      physical_instantiation.dimensions = ["Test dimensions"]
      expect(physical_instantiation.resource.dump(:ttl)).to match(/ebucore#dimensions/)
      expect(physical_instantiation.dimensions.include?("Test dimensions")).to be true
    end
  end

  context "format" do
    let(:physical_instantiation) { FactoryBot.build(:physical_instantiation) }
    it "has format" do
      physical_instantiation.format = "Test format"
      expect(physical_instantiation.resource.dump(:ttl)).to match(/ebucore#hasFormat/)
      expect(physical_instantiation.format.include?("Test format")).to be true
    end
  end

  context "standard" do
    let(:physical_instantiation) { FactoryBot.build(:physical_instantiation) }
    it "has standard" do
      physical_instantiation.standard = "Test standard"
      expect(physical_instantiation.resource.dump(:ttl)).to match(/ebucore#hasStandard/)
      expect(physical_instantiation.standard.include?("Test standard")).to be true
    end
  end

  context "location" do
    let(:physical_instantiation) { FactoryBot.build(:physical_instantiation) }
    it "has location" do
      physical_instantiation.location = "Test location"
      expect(physical_instantiation.resource.dump(:ttl)).to match(/ebucore#locator/)
      expect(physical_instantiation.location.include?("Test location")).to be true
    end
  end

  context "media_type" do
    let(:physical_instantiation) { FactoryBot.build(:physical_instantiation) }
    it "has media_type" do
      physical_instantiation.media_type = "Test media_type"
      expect(physical_instantiation.resource.dump(:ttl)).to match(/terms\/type/)
      expect(physical_instantiation.media_type.include?("Test media_type")).to be true
    end
  end

  context "generations" do
    let(:physical_instantiation) { FactoryBot.build(:physical_instantiation) }
    it "has generations" do
      physical_instantiation.generations = ["Test generations"]
      expect(physical_instantiation.resource.dump(:ttl)).to match(/ebucore#hasGeneration/)
      expect(physical_instantiation.generations.include?("Test generations")).to be true
    end
  end

  context "time_start" do
    let(:physical_instantiation) { FactoryBot.build(:physical_instantiation) }
    it "has time_start" do
      physical_instantiation.time_start = ["Test time_start"]
      expect(physical_instantiation.resource.dump(:ttl)).to match(/ebucore#start/)
      expect(physical_instantiation.time_start.include?("Test time_start")).to be true
    end
  end

  context "duration" do
    let(:physical_instantiation) { FactoryBot.build(:physical_instantiation) }
    it "has duration" do
      physical_instantiation.duration = "Test duration"
      expect(physical_instantiation.resource.dump(:ttl)).to match(/ebucore#duration/)
      expect(physical_instantiation.duration.include?("Test duration")).to be true
    end
  end

  context "colors" do
    let(:physical_instantiation) { FactoryBot.build(:physical_instantiation) }
    it "has colors" do
      physical_instantiation.colors = "Test colors"
      expect(physical_instantiation.resource.dump(:ttl)).to match(/bibframe.html#c_ColorContent/)
      expect(physical_instantiation.colors.include?("Test colors")).to be true
    end
  end

  context "rights_summary" do
    let(:physical_instantiation) { FactoryBot.build(:physical_instantiation) }
    it "has rights_summary" do
      physical_instantiation.rights_summary = ["Test rights_summary"]
      expect(physical_instantiation.resource.dump(:ttl)).to match(/elements\/1.1\/rights/)
      expect(physical_instantiation.rights_summary.include?("Test rights_summary")).to be true
    end
  end

  context "rights_link" do
    let(:physical_instantiation) { FactoryBot.build(:physical_instantiation) }
    it "has rights_link" do
      physical_instantiation.rights_link = ["Test rights_link"]
      expect(physical_instantiation.resource.dump(:ttl)).to match(/europeana.eu\/rights/)
      expect(physical_instantiation.rights_link.include?("Test rights_link")).to be true
    end
  end

  context "annotation" do
    let(:physical_instantiation) { FactoryBot.build(:physical_instantiation) }
    it "has annotation" do
      physical_instantiation.annotation = ["Test annotation"]
      expect(physical_instantiation.resource.dump(:ttl)).to match(/02\/skos\/core#note/)
      expect(physical_instantiation.annotation.include?("Test annotation")).to be true
    end
  end

  context "local_instantiation_identifier" do
    let(:physical_instantiation) { FactoryBot.build(:physical_instantiation) }
    it "has local_instantiation_identifier" do
      physical_instantiation.local_instantiation_identifier = ["Test local_instantiation_identifier"]
      expect(physical_instantiation.resource.dump(:ttl)).to match(/pbcore.org#localInstantiationIdentifie/)
      expect(physical_instantiation.local_instantiation_identifier.include?("Test local_instantiation_identifier")).to be true
    end
  end

  context "tracks" do
    let(:physical_instantiation) { FactoryBot.build(:physical_instantiation) }
    it "has tracks" do
      physical_instantiation.tracks = "Test tracks"
      expect(physical_instantiation.resource.dump(:ttl)).to match(/pbcore.org#hasTracks/)
      expect(physical_instantiation.tracks.include?("Test tracks")).to be true
    end
  end

  context "channel_configuration" do
    let(:physical_instantiation) { FactoryBot.build(:physical_instantiation) }
    it "has channel_configuration" do
      physical_instantiation.channel_configuration = "Test channel_configuration"
      expect(physical_instantiation.resource.dump(:ttl)).to match(/pbcore.org#hasChannelConfiguration/)
      expect(physical_instantiation.channel_configuration.include?("Test channel_configuration")).to be true
    end
  end

  context "alternative_modes" do
    let(:physical_instantiation) { FactoryBot.build(:physical_instantiation) }
    it "has alternative_modes" do
      physical_instantiation.alternative_modes = "Test alternative_modes"
      expect(physical_instantiation.resource.dump(:ttl)).to match(/pbcore.org#hasAlternativeModes/)
      expect(physical_instantiation.alternative_modes.include?("Test alternative_modes")).to be true
    end
  end

  context "holding_organization" do
    let(:physical_instantiation) { FactoryBot.build(:physical_instantiation) }
    it "has holding_organization" do
      physical_instantiation.holding_organization = "Test holding_organization"
      expect(physical_instantiation.resource.dump(:ttl)).to match(/pbcore.org#hasHoldingOrganization/)
      expect(physical_instantiation.holding_organization.include?("Test holding_organization")).to be true
    end
  end

  describe '#destroy' do
    before do
      @ordered_members = [
        create_list(:essence_track, rand(1..3)),
        create_list(:contribution, rand(1..3))
      ].flatten

      # Create, with children
      physical_instantiation = create(
        :physical_instantiation,
        ordered_members: @ordered_members
      )

      # Now destroy what we've just created
      physical_instantiation.destroy!
    end

    it 'destroys child EssenceTracks and Contributions' do
      @ordered_members.each do |child|
        expect { child.reload }.to raise_error ActiveFedora::ObjectNotFoundError
      end
    end
  end
end
