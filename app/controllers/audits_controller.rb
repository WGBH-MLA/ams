class AuditsController < ApplicationController
  include ApplicationHelper

  def new
  end

  def create
    ids = split_and_validate_ids(params[:id_field])
    unless ids
      flash[:error] = "There was a problem with your IDs, please try again."
      return render 'new'
    end

    audit_report = AMS::Migrations::Audit::AuditingService.new(asset_ids: ids).report
    @matches = audit_report["matches"]
    @mismatches = audit_report["mismatches"]
    @errors = audit_report["errors"]

    render 'new'
  end

end