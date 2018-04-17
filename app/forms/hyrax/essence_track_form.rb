# Generated via
#  `rails generate hyrax:work EssenceTrack`
module Hyrax
  class EssenceTrackForm < Hyrax::Forms::WorkForm
    self.model_class = ::EssenceTrack
    self.terms += [:date, :dimensions, :format, :standard, :location, :media_type, :generations,:file_size, :time_start, :duration, :data_rate, :colors, :language, :rights_summary, :rights_link, :annotation]
    self.terms -= [:description, :relative_path, :import_url, :date_created, :resource_type, :creator, :contributor, :keyword, :license, :rights_statement, :publisher, :subject, :identifier, :based_near, :related_url, :bibliographic_citation, :source]
    self.required_fields -= [:creator, :keyword, :rights_statement]
    self.required_fields += [:media_type, :format, :location]
  end
end