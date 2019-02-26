module AAPB
  module InstantiationAdminDataPresenter
    extend ActiveSupport::Concern
    included do
      def display_admin_data?
        !(aapb_preservation_lto.blank? &&
            aapb_preservation_disk.blank?
        )
      end
    end
  end

end