ams_config = Rails.application.config_for :ams

Rails.application.configure do
  config.ams = ActiveSupport::OrderedOptions.new
  config.ams.aapb_admin_data_write_role = ams_config[:aapb_admin_data_write_role]
end