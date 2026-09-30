module Hyrax
  # validates that the title has at least one title and it is unique
  class HasOneTitleValidator < ActiveModel::Validator
    def validate(record)
      # validates that the title it is unique
      if record.title.reject(&:empty?).empty?
        record.errors[:title] << I18n.t('hyrax.dashboard.admin_sets.title_cant_blank_validation')
      end
    end
  end
end