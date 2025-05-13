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

            context "with nil annotation_type" do
                let(:annotation) { FactoryBot.build(:annotation, :no_annotation_type, admin_data: admin_data) }

                it "is valid without an annotation_type" do
                    expect(annotation.annotation_type).to be_nil
                    expect(annotation.valid?).to be true
                end
            end
        end
    end
end
