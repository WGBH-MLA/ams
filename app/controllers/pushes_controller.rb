class PushesController < ApplicationController
  include ApplicationHelper
  include Blacklight::SearchHelper
  before_action :authenticate_user!

  include Blacklight::Configurable
  # this v is required - advanced_search will crash without it
  copy_blacklight_config_from(CatalogController)
  configure_blacklight do |config|
    # This is necessary to prevent Blacklight's default value of 100 for
    # config.max_per_page from capping the number of results.
    config.max_per_page = 2147483647
    # config.rows = 2147483647
  end

  def index
    # show all previous pushes
    @pushes = Push.all
  end

  def show
    # view results of push
    @push = Push.find(params[:id])
  end

  def create
    # new push
    # -get set of ids from form + click 'push to aapb'
    # -pull solr_documents from list of ids
    # -render xml for each, and zip dat
    # -return zip
    ids = split_and_validate_ids(params[:id_field])
    unless ids
      flash[:error] = "There was a problem with your IDs, please try again."
      return render 'new'
    end

    query = ""
    query += ids.map { |id| "id:#{id}" }.join(' OR ')

    query_params = {q: query}
    
    query_params[:format] = 'zip-pbcore'
    query_params = delete_extra_params(query_params)
    query_params.delete :controller

    ExportRecordsJob.perform_later(query_params, current_user)
    push = Push.create(user_id: current_user.id, pushed_id_csv: ids.join(',') )
    redirect_to "/pushes/#{push.id}"
  end

  def validate_ids
    requested_ids = split_and_validate_ids(params[:id_field])
    # bad input
    return render json: {error: "There was a problem parsing your IDs. Please check your input and try again."} unless requested_ids && requested_ids.count > 0

    found_ids = []
    requested_ids.each_slice(100).each do |segment|
      query = build_query(segment)
      found_ids += query_ids(query)
    end

    missing_ids = verify_id_set(requested_ids, found_ids)

    all_valid = missing_ids.count == 0 ? true : false
    id_response = {all_valid: all_valid}
    id_response[:missing_ids] = missing_ids unless missing_ids.empty?
    render json: id_response
  end

  def new
    if params[:transfer] == 'true'
      ze_params = params.dup
      query_params = delete_extra_params(ze_params)
      query_params[:fl] = 'id'
      query_params[:rows] = 2147483647

      # regular query
      response, response_documents = search_results(query_params) do |builder|
        builder = AMS::SearchBuilder.new(self).with(query_params)
      end
      params[:id_field] = response_documents.map(&:id).join("\n")
    end

    render 'new'
  end

  def needs_updating
    # Pass a block in to override default search builder's monkeying around
    # Pushbuilder forces correct query params, which are otherwise wiped out
    response, docs = search_results({}) do |builder|
      AMS::PushSearchBuilder.new(self).with({q: 'needs_update:true'})
    end

    if docs.count > 0
      ids = docs.map {|doc| doc[:id]}.join("\n")
      redirect_to action: 'new', id_field: ids
    else
      # sorry!
      redirect_to new_push_path
    end
  end
end
