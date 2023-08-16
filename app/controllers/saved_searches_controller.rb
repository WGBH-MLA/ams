# frozen_string_literal: true
class SavedSearchesController < ApplicationController
  # TODO what is the replacement?
  if App.rails_5_1?
    include Blacklight::SavedSearches
  end

  helper BlacklightAdvancedSearch::RenderConstraintsOverride
end
