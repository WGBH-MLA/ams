class PushesController < ApplicationController
  include ApplicationHelper
  include Blacklight::SearchHelper
  before_action :authenticate_user!

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

    ExportRecordsJob.perform_later(query_params, current_user)
    push = Push.create(user_id: current_user.id, pushed_id_csv: ids.join(',') )
    redirect_to "/pushes/#{push.id}"
  end

  def validate_ids
    requested_ids = split_and_validate_ids(params[:id_field])
    # bad input
    return render json: {error: "There was a problem parsing your IDs. Please check your input and try again."} unless requested_ids && requested_ids.count > 0

    query = ""
    query += requested_ids.map { |id| "id:#{id}" }.join(' OR ')

    # use this builder so default one doesnt add fq to break our query!!
    response, response_documents = search_results({q: query}) do |builder|
      AMS::PushSearchBuilder.new(self)
    end

    found_ids_set = Set.new( response_documents.map(&:id) )
    requested_ids_set = Set.new(requested_ids)

    # get exclusive items, remove those exclusive to found_ids
    missing_ids = (requested_ids_set ^ found_ids_set).subtract(found_ids_set)

    all_valid = missing_ids.count == 0 ? true : false
    id_response = {all_valid: all_valid}
    id_response[:missing_ids] = missing_ids unless missing_ids.empty?
    id_response[:id_query] = query
    render json: id_response
  end

  def transfer_query
    query_params = delete_extra_params(params)
    query_params[:fl] = 'id'

    # regular query
    response, response_documents = search_results(query_params)
    ids = response_documents.map(&:id).join("\n")
    redirect_to action: 'new', id_field: ids
  end

  def needs_updating
    # Pass a block in to override default search builder's monkeying around
    # Pushbuilder forces correct query params, which are otherwise wiped out
    response, docs = search_results({q: 'needs_update:true'}) do |builder|
      AMS::PushSearchBuilder.new(self)
    end

    if docs.count > 0
      ids = docs.map {|doc| doc[:id]}.join("\n")
      redirect_to action: 'new', id_field: ids
    else
      # sorry!
      redirect_to pushes_path
    end
  end
end
