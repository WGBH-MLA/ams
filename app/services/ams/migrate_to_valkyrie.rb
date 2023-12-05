# frozen_string_literal: true
require 'ruby-progressbar'

module AMS
  class MigrateToValkyrie < AMS::WorkReprocessor
    def initialize
      super(dir_name: 'migrate_to_valkyrie')
      @query = "(has_model_ssim:DigitalInstantiation OR has_model_ssim:PhysicalInstantiation OR has_model_ssim:Asset OR has_model_ssim:EssenceTrack OR has_model_ssim:Contribution)"
    end

    def run_on_id(id)
      work = Hyrax.query_service.find_by(id: id)
      work.save
    end
  end
end
