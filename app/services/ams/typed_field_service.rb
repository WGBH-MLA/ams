module AMS
  class TypedFieldService < Hyrax::QaSelectService
    attr_reader :type

    def initialize(authority_name, type)
      @type = type
      super(authority_name)
    end

    def all_terms
      select_all_options.map { |(term, _id)| term }
    end

    def all_ids
      select_all_options.map { |(_term, id)| id }
    end

    # @param id of the field needs mapping to model
    # @return [String] Returns mapping for type to model field
    def model_field(id)
      case id
        when "main"
          model_field = @type
      else
        model_field = "#{id}_#{@type}"
      end
      model_field
    end
  end
end
