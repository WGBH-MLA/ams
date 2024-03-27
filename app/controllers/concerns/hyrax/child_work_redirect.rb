module Hyrax::ChildWorkRedirect
  extend ActiveSupport::Concern

  def after_create_response
    respond_to do |wants|
      wants.html do
        # Calling `#t` in a controller context does not mark _html keys as html_safe
        flash[:notice] = view_context.t('hyrax.works.create.after_create_html', application_name: view_context.application_name)
        if(params.has_key?(:child_work_create) && !params.fetch("child_work_create").blank? && curation_concern.valid_child_concerns.include?(params.fetch("child_work_create").constantize))
          redirect_to polymorphic_path([main_app, :new, :hyrax, :parent, params.fetch("child_work_create").underscore.to_sym], parent_id: curation_concern.id)
        else
          redirect_to [main_app, curation_concern]
        end
      end
      wants.json { render :show, status: :created, location: polymorphic_path([main_app, curation_concern]) }
    end
  end

  def after_update_response
    if curation_concern.try(:file_sets).present? || Hyrax.custom_queries.find_child_file_sets(resource: curation_concern).to_a.present?
      return redirect_to hyrax.confirm_access_permission_path(curation_concern) if permissions_changed?
      return redirect_to main_app.confirm_hyrax_permission_path(curation_concern) if curation_concern.visibility_changed?
    end
    respond_to do |wants|
      wants.html do
        flash[:notice] = "Work \"#{curation_concern}\" successfully updated."
        if(params.has_key?(:child_work_create) && !params.fetch("child_work_create").blank? && curation_concern.valid_child_concerns.include?(params.fetch("child_work_create").constantize))
          redirect_to polymorphic_path([main_app, :new, :hyrax, :parent, params.fetch("child_work_create").underscore.to_sym], parent_id: curation_concern.id)
        else
          redirect_to [main_app, curation_concern]
        end
      end
      wants.json { render :show, status: :ok, location: polymorphic_path([main_app, curation_concern]) }
    end
  end
end
