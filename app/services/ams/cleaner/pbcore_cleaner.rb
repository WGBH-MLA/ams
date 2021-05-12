module AMS
  module Cleaner
    class PBCoreCleaner

      def initialize(pbcore)
        raise 'PBCoreCleaner must be initialized with a PBCore::DescriptionDocument' unless pbcore.class == PBCore::DescriptionDocument
        @pbcore = pbcore
      end

      def clean!
        pipeline.process(@pbcore)
      end

      private

      def pipeline
        Pipeline.new(pipeline_steps)
      end

      def pipeline_steps
        [
          Steps::CleanAssetTypes,
          Steps::CleanDateTypes,
          Steps::CleanAssetDescriptionTypes,
          Steps::DeleteEmptyTitles,
          Steps::AddUnknownTitleIfMissing
        ]
      end
    end
  end
end