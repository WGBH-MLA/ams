class Batch < ApplicationRecord
  has_many :batch_items, dependent: :destroy

  def deposit_user
    if submitter.nil?
      User.first
    else
      User.find_or_create_by(email: submitter)
    end
  end

  def status
    return 'empty'       if statuses.empty?
    return 'error'       if statuses.include?('error')
    return 'complete'    if statuses.all? { |s| ['complete', 'skipped'].include?(s) }
    return 'initialized' if statuses == ['initialized']
    'processing'
  end

  private

    def statuses
      batch_items.collect(&:status).sort.uniq
    end
end
