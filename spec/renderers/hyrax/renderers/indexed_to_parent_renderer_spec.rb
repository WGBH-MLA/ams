# Generated via
#  `rails generate hyrax:work Asset`
require 'rails_helper'

RSpec.describe Hyrax::Renderers::IndexedToParentRenderer do
  let(:expected_html) { "<dt>Media type</dt>\n<dd><ul class='tabular'><li class=\"attribute attribute-media_type\"><a href=\"/catalog?f%5Bmedia_type_ssim%5D%5B%5D=Moving+Image&amp;locale=en\">Moving Image</a></li></ul></dd>" }
  let(:subject) { Hyrax::Renderers::IndexedToParentRenderer.new(:media_type, ["Moving Image"] , {:render_as => :faceted, :html_dl => true}).render }

  it "#render" do
    expect(subject).to eq(expected_html)
  end
end