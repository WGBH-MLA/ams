class PushesController < ApplicationController
  include ApplicationHelper
  include Blacklight::SearchHelper

  # regular OR searches messed up using push searchbuilder...
  # def search_builder_class
  #   AMS::PushSearchBuilder
  # end

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
    # ids = params[:id_field].split(/\s/).reject(&:empty?)
    ids = split_and_validate_ids(params[:id_field])
    unless ids
      flash[:error] = "There was a problem with your IDs, please try again."
      return render 'new'
    end    

    query = ""
    if ids.count > 1
      ids.each_with_index do |id, index|
        next if index == (ids.count-1)
        query += %(#{id} OR )
      end
    end
    query += %(#{ids.last})
    
    query_params = {q: query}
    query_params[:format] = 'zip-pbcore'
    # query_params[:rows] = 2147483647
    query_params = delete_extra_params(query_params)
    require('pry');binding.pry
    ExportRecordsJob.perform_later(query_params, current_user)
    push = Push.create(user_id: current_user.id, pushed_id_csv: ids.join(',') )

    
    # flash[:notice] = "Your IDs have been accepted."
    # render 'pb_to_aapb_form'
    redirect_to "/pushes/#{push.id}"
  end  

  def validate_ids
    requested_ids = split_and_validate_ids(params[:id_field])
    # bad input
    return render json: {error: "There was a problem parsing your IDs. Please check your input and try again."} unless requested_ids && requested_ids.count > 0

    query = ""
    if requested_ids.count > 1
      requested_ids.each_with_index do |id, index|
        next if index == (requested_ids.count-1)
        query += %(#{id} OR )
      end
    end

    query += %(#{requested_ids.last})
    query_params = {q: query}
    response, response_documents = search_results(query_params)

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
    # query_params[:rows] = 2147483647

    # restrict to asset results
    # query_params[:fq] ||= []
    # query_params[:fq] << "{!terms f=has_model_ssim}Asset"

    response, response_documents = search_results(query_params)
    # TODO: make :fl query work? catcon default works, gets thrown away here :/
    ids = response_documents.map(&:id).join("\n")
    redirect_to action: 'new', id_field: ids
  end

  def needs_updating
    # (last_updated - last_pushed) > 0
    # query = { q: %( if(gt(sub(last_updated, last_pushed),0)), true, false), rows: 2147483647}
    # query = { q: %({!func}if(gt(sub(last_updated, last_pushed),0)), true, false), rows: 2147483647}
    # query = { qf: 'last_updated, last_pushed', q: %({!func}gt(sub(last_updated, last_pushed),0), true, false), rows: 2147483647}
    # query = %({!func}sub(last_updated_ssim, last_pushed_ssim))
    # fq=%({!frange l=0 u=*}sub(last_updated_ssim, last_pushed_ssim))
    # fq = %(_val_: {0 TO *])
    # query=%({!frange l=0 u=*}"sub(last_updated, last_pushed_ssim)")
    # full = {q: query}
    # query=%(_val_:'gt(sub(last_updated, last_pushed),0)')

    # fq = []
    # # fq << %(needs_update: true)
    # # must be fq
    # # why not q? no idea, it doesn't make sense!

    # # restrict to Asset results
    # fq << 

    # rows: 2147483647, q: "has_model_ssim:Asset"


    # Pass a block in to override default search builder's monkeying around
    # Pushbuilder forces correct query params, which are otherwise wiped out
    response, docs = search_results({}) do |builder|
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
