# OVERRIDE Hyrax 5.0 to add basic metadata to collection

Hyrax::AdministrativeSet.class_eval do
  include Hyrax::ArResource
end
