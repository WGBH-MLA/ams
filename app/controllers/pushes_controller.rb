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
    @push = Push.new(user_id: current_user.id, pushed_id_csv: pushed_id_csv_from_id_field )
    if @push.valid?
      search_for_ids_only = { fq: "id:(#{@push.push_ids.join(' OR ')})"}
      ExportRecordsJob.perform_later(export_type: :push_to_aapb, search_params: search_for_ids_only, user: current_user)
      @push.save!
      redirect_to @push
    else
      render :new
    end
  end

  # #validate_ids aynchronous validation of IDs to be pushed to AAPB.
  def validate_ids
    response = {}
    @push = Push.new(user: current_user, pushed_id_csv: pushed_id_csv_from_id_field)
    response[:error] = @push.errors.values.flatten.join("\n\n") if @push.invalid?
    render json: response
  end

  def new
    # If we have search params but no explicitly passed IDs in :id_field, then
    # do the search and set the :id_field to the found IDs.
    if (search_params[:q] || search_params[:fq] && !params[:id_field])
      params[:id_field] = assets_search.solr_documents.map(&:id).join("\n")
    end
  end

  # TODO: Is anyone using this? I don't see it linked anywhere, so I think it's
  # just a convenience route that users would have to remember.
  def needs_updating
    redirect_to action: :new, fq: 'needs_update:true'
  end

  private

    # Converting a list of values from the id_field (a texteara in the #new
    # view) to a comma-separated list of IDs.
    def pushed_id_csv_from_id_field
      params.fetch(:id_field, '').split(/\s+/).reject(&:empty?).uniq.join(',')
    end

    def assets_search
      @asset_search ||= AMS::Export::Search::AssetsSearch.new(search_params: search_params, user: current_user)
    end

    def search_params
      @search_params ||= params.dup.
                                permit!.
                                except(:page, :per_page, :action, :controller, :locale).
                                merge(rows: AMS::Export::Search::Base::MAX_LIMIT)
    end
end
