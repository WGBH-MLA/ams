module ApplicationHelper

  # Module method for displaying dates consistently.
  # Usage: ApplicationHelper.display_date
  def self.display_date(date_time, format: '%Y-%m-%d', from_format: nil, time_zone: nil)
    parsed_time = if from_format
      DateTime.strptime(date_time.to_s, from_format)
    else
      DateTime.strptime(date_time.to_s)
    end

    parsed_time = parsed_time.in_time_zone(time_zone) if time_zone
    parsed_time.strftime(format)
  rescue => error
    Rails.logger.warn "Caught exception #{error.class}: #{error.message}\n#{error.backtrace.join("\n")}"
    nil
  end

  # Instance method delegates to ApplicationHelper.display_date.
  def display_date(*args); ApplicationHelper.display_date(*args); end

  def render_thumbnail(document, options)
    # send(blacklight_config.view_config(document_index_view_type).thumbnail_method, document, image_options)
    url = thumbnail_url(document).gsub('cpb-aacip-', 'cpb-aacip_')
    image_tag url, options if url.present?
  end

  def user_can_delete?(user)
    user.roles.any? {|r| r.name == 'aapb-admin'}
  end

  def query_docs(query)

    response, response_documents = search_results({}) do |builder|
      # must pass in with .with here, search_results({q: ...}) is discarded
      AMS::PushSearchBuilder.new(self).with({q: query, rows: 2147483647})
    end

    response_documents
  end

  def query_ids(query)
    query_docs(query).map(&:id)
  end
end
