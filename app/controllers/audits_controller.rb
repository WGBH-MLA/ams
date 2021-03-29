class AuditsController < ApplicationController
  include ApplicationHelper

  def new
    @ids = params.fetch(:id_field, '').split(/\s+/).reject(&:empty?).uniq
    create_report if @ids
  end

  def create
    redirect_to new_audit_path(request.parameters)
  end

  private

  def create_report
    audit_report = AMS::Migrations::Audit::AuditingService.new(asset_ids: @ids, user: current_user).report
    @matches = audit_report["matches"]
    @mismatches = audit_report["mismatches"]
    @errors = audit_report["errors"]
  end
end