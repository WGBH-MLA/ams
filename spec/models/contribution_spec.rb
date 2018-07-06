# Generated via
#  `rails generate hyrax:work Asset`
require 'rails_helper'

RSpec.describe Contribution do

  context "title" do
    let(:contribution) { FactoryBot.build(:contribution) }
    it "has title" do
      contribution.title = ["Test title 1","Test title 2"]
      expect(contribution.resource.dump(:ttl)).to match(/terms\/title/)
      expect(contribution.title.include?("Test title 1")).to be true
    end
  end

  context "contributor" do
    let(:contribution) { FactoryBot.build(:contribution) }
    it "has contributor" do
      contribution.contributor = ["Test contributor"]
      expect(contribution.resource.dump(:ttl)).to match(/elements\/1.1\/contributor/)
      expect(contribution.contributor.include?("Test contributor")).to be true
    end
  end

  context "contributor_role" do
    let(:contribution) { FactoryBot.build(:contribution) }
    it "has contributor_role" do
      contribution.contributor_role = "Actor"
      expect(contribution.resource.dump(:ttl)).to match(/2006\/vcard\/ns#hasRole/)
      expect(contribution.contributor_role.include?("Actor")).to be true
    end
  end

  context "portrayal" do
    let(:contribution) { FactoryBot.build(:contribution) }
    it "has portrayal" do
      contribution.portrayal = "Test portrayal"
      expect(contribution.resource.dump(:ttl)).to match(/ebucore\/ebucore#hasCastRole/)
      expect(contribution.portrayal.include?("Test portrayal")).to be true
    end
  end
  context "affiliation" do
    let(:contribution) { FactoryBot.build(:contribution) }
    it "has affiliation" do
      contribution.portrayal = "Test affiliation"
      expect(contribution.resource.dump(:ttl)).to match(/ebucore\/ebucore#hasAffiliation/)
      expect(contribution.portrayal.include?("Test affiliation")).to be true
    end
  end
end
