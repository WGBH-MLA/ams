module ApplicationHelper

  def split_and_validate_ids(input)
    return false unless input =~ /[a-z0-9\-_\/\n]/
    ids = input.split(/\s/).reject(&:empty?)

    return false unless ids.all? {|id| /\Acpb-aacip[\-_\/][0-9]{1,3}[\-_\/][a-zA-Z0-9]+\z/ =~ id || /\Acpb-aacip[\-_\/][a-zA-Z0-9]+\z/ =~ id }

    ids
  end

  def delete_extra_params(params)
    params.delete :page
    params.delete :per_page
    params.delete :action
    # params.delete :controller
    params.delete :locale
    params.delete :transfer
    # woo!
    params
  end

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

  def build_query(ids)
    query = ""
    query += ids.map { |id| %(id:#{id}) }.join(' OR ')
    query = "(#{query})"
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

  def verify_id_set(requested_ids, found_ids)
    found_ids_set = Set.new( found_ids )
    requested_ids_set = Set.new( requested_ids )

    # get exclusive items, remove those exclusive to found_ids
    (requested_ids_set ^ found_ids_set).subtract(found_ids_set)
  end
end
