require "active_support/core_ext/hash/indifferent_access"
require 'ams/export/search'
require 'ams/export/results'
require 'ams/export/delivery'

module AMS::Export
  class << self
    def types
      [:push_to_aapb, :asset, :physical_instantiation, :digital_instantiation]
    end

    def valid_type?(type)
      types.include? type
    end
  end
end
