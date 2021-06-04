require 'ams/cleaner/pbcore_element_editor'

module AMS
  module Cleaner
    module Steps

      class CleanAssetTypes
        def self.process(pbcore)
          pbcore.asset_types.map{ |type| type.value = PBCoreElementEditor.new(element: type).value }
          pbcore
        end
      end

      class CleanDateTypes
        def self.process(pbcore)
          pbcore.asset_dates.map{ |date| date.type = PBCoreElementEditor.new(element: date).type }
          pbcore
        end
      end

      class CleanAssetDescriptionTypes
        def self.process(pbcore)
          pbcore.descriptions.map{ |desc| desc.type = PBCoreElementEditor.new(element: desc).type }
          pbcore
        end
      end

      class DeleteEmptyTitles
        def self.process(pbcore)
          pbcore.titles.reject!{ |title| title.value.empty? }
          pbcore
        end
      end

      class AddUnknownTitleIfMissing
        def self.process(pbcore)
          pbcore.titles << PBCore::Title.new(type: "unknown", value: "unknown") if pbcore.titles.empty?
          pbcore
        end
      end

    end
  end
end
