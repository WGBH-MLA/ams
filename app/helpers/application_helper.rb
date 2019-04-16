module ApplicationHelper

  def split_and_validate_ids(input)
    return false unless input =~ /[a-z0-9\-_\/\n]/
    ids = input.split(/\s/).reject(&:empty?)
    return false unless ids.all? {|id| /cpb-aacip-[a-zA-Z0-9]{10}/ ~= id }
    ids
  end
end
