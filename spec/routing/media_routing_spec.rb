require 'rails_helper'

RSpec.describe 'routes for SonyCi media files', type: :routing do
  it 'routes /media/[id] to the #show action of the media controller' do
    expect(get("/media/123")).to route_to controller: 'media', action: 'show', id: '123'
  end
end
