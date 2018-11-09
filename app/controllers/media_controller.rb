require 'sony_ci_api'

class MediaController < ApplicationController

  def show
    ci = SonyCiBasic.new(credentials_path: Rails.root + 'config/ci.yml')
    require 'pry'; binding.pry
    # OAuth credentials expire: otherwise it would make sense to cache this instance.
    redirect_to ci.download(pbcore.ci_ids[(params['part'] || 1).to_i - 1])
  end
end
