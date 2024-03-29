# Return TRUE if expected_prepnded_module comes before prepending_class in
# the prepending_class's ancestor list.
RSpec::Matchers.define :have_prepended do |expected_prepended_module|
  match do |prepending_class|
    prepending_class.ancestors.index(prepending_class) > prepending_class.ancestors.index(expected_prepended_module)
  end
end

module HyraxCapybaraMatchers
  # Returns a matcher for whether the given record is in the search results.
  def have_search_result(record)
    raise ArgumentError, "First argument to have_search_results must respond to :id, but a #{record.class} was given" unless record.respond_to? :id
    have_css("#search-results li#document_#{record.id}")
  end

  # Returns a matcher for whether all the given records given are in the search
  # results.
  def have_search_results(records=[])
    records = records.dup
    initial_matcher = have_search_result(records.shift) if records.first
    records.reduce(initial_matcher) { |memo, record| memo.and( have_search_result(record) ) }
  end

  # Returns a matcher for whether the given records are the ONLY recrods in the
  # serach results.
  def only_have_search_results(records=[])
    # Has all of the records in the search results...
    have_search_results(records).and(
      # ... and only has records.count search results.
      have_css( '#search-results li.document', count: records.count )
    )
  end
end

# Include these custom matchers in RSpec.
RSpec.configure { |c| c.include HyraxCapybaraMatchers }

RSpec::Matchers.define :exist_in_repository do
  match do |obj_id|
    begin
      Hyrax.query_service.find_by(id: obj_id)
      true
    rescue Valkyrie::Persistence::ObjectNotFoundError
      false
    end
  end
end

RSpec::Matchers.define :not_exist_in_repository do
  match do |obj_id|
    begin
      Hyrax.query_service.find_by(id: obj_id)
      false
    rescue Valkyrie::Persistence::ObjectNotFoundError
      true
    end
  end
end
