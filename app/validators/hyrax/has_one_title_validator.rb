module Hyrax
  # validates that the title has at least one title and it is unique
  class HasOneTitleValidator < ActiveModel::Validator
    def validate(record)
      # validates that the title it is unique
      if record.new_record? && AdminSet.where(title: record.title[0]).present?
        return record.errors[:title] << "#{I18n.t('hyrax.dashboard.admin_sets.admin_set')} #{record.title[0]} #{I18n.t('hyrax.dashboard.admin_sets.title_unique_validation')}"
        # validates that the title has at least one title
      elsif record.title.reject(&:empty?).empty?
        return record.errors[:title] << I18n.t('hyrax.dashboard.admin_sets.title_cant_blank_validation')
      end
    end
  end
end