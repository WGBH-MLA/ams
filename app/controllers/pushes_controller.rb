class PushesController < ApplicationController
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
    @push = Push.create(user_id: current_user.id, status: 'initiated', pushed_id_csv: submitted_ids)
    if @push.valid?
      SavePushJob.perform_later(push: @push)
      redirect_to @push
    else
      render :new
    end
  end

  # #validate_ids aynchronous validation of IDs to be pushed to AAPB.
  def validate_ids
    response = {}
    @push = Push.new(user: current_user, asset_ids_queue: submitted_ids)
    response[:error] = @push.errors.values.flatten.join("\n\n") if @push.invalid?
    render json: response
  end

  def new
    # If we have search params but no explicitly passed IDs in :asset_ids_queue, then
    # do the search and set the :asset_ids_queue to the found IDs.
    if (search_params[:q] || search_params[:fq] && !params[:asset_ids_queue])
      params[:asset_ids_queue] = assets_search.solr_documents.map(&:id).join("\n")
    end
  end

  # TODO: Is anyone using this? I don't see it linked anywhere, so I think it's
  # just a convenience route that users would have to remember.
  def needs_updating
    redirect_to action: :new, fq: 'needs_update:true'
  end

  private

    # Converting a list of values from the asset_ids_queue (a texteara in the #new
    # view) to a comma-separated list of IDs.
    def submitted_ids
      params.fetch(:asset_ids_queue, '').split(/\s+/).reject(&:empty?).uniq
    end

    def assets_search
      @asset_search ||= AMS::Export::Search::CatalogSearch.new(search_params: search_params, user: current_user)
    end

    def search_params
      @search_params ||= params.dup.
                                permit!.
                                except(:page, :per_page, :action, :controller, :locale).
                                merge(rows: AMS::Export::Search::Base::MAX_LIMIT)
    end
end
