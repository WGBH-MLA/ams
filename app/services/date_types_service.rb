

module DateTypesService
  mattr_accessor :authority
  self.authority = Qa::Authorities::Local.subauthority_for('date_types')

  def self.select_all_options
    authority.all.map do |element|
      [element[:label], element[:id]]
    end
  end

  def self.all_terms
    select_all_options.map { |(term, id)| term }
  end

  def self.all_ids
    select_all_options.map { |(term, id)| id }
  end

  def self.label(id)
    authority.find(id).fetch('term')
  end
end