module AMS
  module CreateMemberMethods
    extend ActiveSupport::Concern

    included do
      def create_child_methods
        self.valid_child_concerns.each do |child_class|
          # name with _resources gives us valkyrie or af record - digital_instantation_resouces
          method_name = child_class.to_s.underscore.pluralize
          self.class.send(:define_method, method_name) do
            self.members.select { |work| work.is_a?(child_class) }
          end

          # name with out _resources gives us solr record - digital_instantation
          method_name = child_class.to_s.underscore.gsub(/_resour.*/, '').pluralize
          self.class.send(:define_method, method_name) do
            case self
            when ActiveFedora::Base
              condition = { has_model_ssim: child_class.to_s, id: self.members.map(&:id) }
              ActiveFedora::Base.search_with_conditions(condition).collect { |v| SolrDocument.new(v) }
            when Valkyrie::Resource
              child_works_of_type = members.select { |work| work.is_a?(child_class) }
              child_works_of_type.map { |work| resource_to_solr(work) }
            end
          end
        end
      end

      def resource_to_solr(resource)
        indexable_hash = Hyrax::ValkyrieIndexer.for(resource: resource).to_solr
        ::SolrDocument.new(indexable_hash)
      end

      after_initialize :create_child_methods if self.ancestors.include?(ActiveFedora::Base)
    end
  end
end
