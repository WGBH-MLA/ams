# This is a fix for a bug in Hyrax where under certain circumstances the minter
# stops issuing new IDs, preventing new objects from being created.
# See https://github.com/samvera/hyrax/issues/3128 for more details.
::Noid::Rails.config.identifier_in_use = lambda do |id|
  ActiveFedora::Base.exist?(id) || ActiveFedora::Base.gone?(id)
end


# Use the last set of items to creat the tree path in Fedora
# because all of our ids have a first set that match.

::Noid::Rails.module_eval do
  class << self
    def treeify(identifier, new_style = true)
      raise ArgumentError, 'Identifier must be a string of size > 0 in order to be treeified' if identifier.blank?
      head = identifier.split('/').first
      head.gsub!(/#.*/, '')
      if identifier.match(/^cpb-aacip/) && new_style
        (head.scan(/..?/)[-5..-2] + [identifier]).join('/')
      else
        (head.scan(/..?/).first(4) + [identifier]).join('/')
     end
    end
  end
end
