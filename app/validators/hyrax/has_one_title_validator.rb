module Hyrax
  # validates that the title has at least one title and it is unique
  class HasOneTitleValidator < ActiveModel::Validator
    def validate(record)
      # validates that the title it is unique
      if record.new_record? && AdminSet.where(title: record.title[0]).present?
        return record.errors[:title] << "Administrative set #{record.title[0]} already exist try another one"
        # validates that the title has at least one title
      elsif record.title.reject(&:empty?).empty?
        return record.errors[:title] << "You must provide a title"
      end
    end
  end
end