class AuditsController < ApplicationController
  include ApplicationHelper

  def new
  end

  def create
    ids = params.fetch(:id_field, '').split(/\s+/).reject(&:empty?).uniq

    audit_report = AMS::Migrations::Audit::AuditingService.new(asset_ids: ids, user: current_user).report
    @matches = audit_report["matches"]
    @mismatches = audit_report["mismatches"]
    @errors = audit_report["errors"]

    render 'new'
  end

end