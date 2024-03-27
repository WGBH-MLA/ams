class SonyCiIdInput < MultiValueInput
  def build_field(value, index)
    super + sony_ci_filename_html(value).to_s.html_safe
  end

  private

    def sony_ci_filename_html(sony_ci_id)
      # NOTE: object.model.admin_data will be FALSE if this is a new record so
      # we need to guard against that.
      filename = if object.model.admin_data.present?
        object.model.admin_data.sonyci_records&.fetch(sony_ci_id, nil)&.fetch('name', nil)
                 end
      if filename.present?
        "<p style='width: 100%'>Filename: <span class=\"sony_ci_filename\">#{filename}</span></p>"
      else
        ''
      end
    end
end
