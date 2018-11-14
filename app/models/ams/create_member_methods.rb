module AMS
  module CreateMemberMethods

    def self.included(klass)
      klass.class_eval do
        after_initialize :create_child_methods
      end
    end

    def create_child_methods
      self.valid_child_concerns.each do |child_class|
        method_name = child_class.to_s.underscore.pluralize
        self.class.send(:define_method,method_name) do
          condition= {has_model_ssim:child_class.to_s, id:self.members.map(&:id)}
          ActiveFedora::Base.search_with_conditions(condition).collect { |v| SolrDocument.new(v) }
        end
      end
    end
  end
end