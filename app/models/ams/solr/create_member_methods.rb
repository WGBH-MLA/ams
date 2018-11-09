module AMS
  module Solr
    module CreateMemberMethods
      def find_child(klass, ids=nil)
        raise "param klass needs to be a ruby class" if !klass.class.is_a?(Class)
        raise "not a valid child class" if !self["has_model_ssim"].first.constantize.valid_child_concerns.include?(klass)
        ids = self['member_ids_ssim'] if ids.nil?
        condition= {has_model_ssim:klass.to_s, id:Array(ids)}
        ActiveFedora::Base.search_with_conditions(condition).collect { |v| SolrDocument.new(v) }
      end
    end
  end
end