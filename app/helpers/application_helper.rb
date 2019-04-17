module ApplicationHelper

  def split_and_validate_ids(input)
    return false unless input =~ /[a-z0-9\-_\/\n]/
    ids = input.split(/\s/).reject(&:empty?)
    return false unless ids.all? {|id| /cpb-aacip[\-_\/][a-zA-Z0-9\-]{11}/ =~ id && id.length >= 19 && id.length <= 22 }
    ids
  end

  def delete_extra_params(params)
    params.delete :page
    params.delete :per_page
    params.delete :action
    params.delete :controller
    params.delete :locale
    # woo!
    params
  end
end
