module ApplicationHelper

  def split_and_validate_ids(input)
    return false unless input =~ /[a-z0-9\-_\/\n]/
    ids = input.split(/\s/).reject(&:empty?)
    return false unless ids.all? {|id| id.length == 21 }
    ids
  end
end
