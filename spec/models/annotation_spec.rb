require 'rails_helper'

RSpec.describe Annotation, type: :model do

  describe "attributes" do
    context "without AdminData" do
      let(:annotation) { FactoryBot.build(:annotation) }
      it "is invalid" do
        expect(annotation.valid?).to be false
      end
    end

    context "with AdminData" do
      let(:admin_data) { FactoryBot.create(:admin_data) }

      context "and all data" do
        let(:annotation) { FactoryBot.build(:annotation, admin_data: admin_data) }

        it "is valid" do
          expect(annotation.valid?).to be true
        end
      end

      context "and no value" do
        let(:annotation) { FactoryBot.build(:annotation, :no_value, admin_data: admin_data) }

        it "is invalid" do
          expect(annotation.valid?).to be false
        end
      end

      context "a relationship is established" do
        let!(:annotation) { FactoryBot.create(:annotation, admin_data: admin_data) }

        it "can access annotations from AdminData" do
          expect(admin_data.reload.annotations.first).to eq(annotation)
        end
      end

      context "has a Supplemental Material annotation_type and no ref attribute" do
        let!(:annotation) { FactoryBot.build(:annotation, annotation_type: "supplemental_material", ref: nil, admin_data: admin_data) }
        it "is invalid without a ref attribute" do
          expect(annotation.valid?).to be false
        end
      end
    end
  end
end
