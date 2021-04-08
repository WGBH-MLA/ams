# Generated via
#  `rails generate hyrax:work PhysicalInstantiation`
class PhysicalInstantiation < ActiveFedora::Base
  include ::Hyrax::WorkBehavior
  include ::AMS::CreateMemberMethods
  include ::AMS::IdentifierService
  include ::AMS::CascadeDestroyMembers

  self.indexer = PhysicalInstantiationIndexer
  # Change this to restrict which works can be added as a child.
  self.valid_child_concerns = [EssenceTrack]

  before_save :save_instantiation_admin_data

  validates :format, presence: { message: 'Your work must have a format.' }
  validates :location, presence: { message: 'Your work must have a location.' }
  validates :media_type, presence: { message: 'Your work must have a media type.' }
  validates :duration, format: { with: AMS::TimeCodeService.regex, allow_blank: true, message: "Invalid format for duration. Use HH:MM:SS, H:MM:SS, MM:SS, or M:SS" }
  # Custom validation block for time_start multi-valued field.
  validate do |physical_instantiation|
    time_start = physical_instantiation.time_start
    if time_start.present? && AMS::TimeCodeService.regex !~ time_start
      errors.add(:time_start, "Invalid format for duration. Use HH:MM:SS, H:MM:SS, MM:SS, or M:SS")
    end
  end

  property :date, predicate: ::RDF::URI.new("http://purl.org/dc/terms/date"), multiple: true, index_to_parent: true do |index|
    index.as :stored_searchable, :facetable
  end

  property :digitization_date, predicate: ::RDF::URI.new("http://www.ebu.ch/metadata/ontologies/ebucore/ebucore#dateDigitised"), multiple: false do |index|
    index.as :stored_searchable
  end

  property :dimensions, predicate: ::RDF::URI.new("http://www.ebu.ch/metadata/ontologies/ebucore/ebucore#dimensions"), multiple: true do |index|
    index.as :stored_searchable
  end

  property :format, predicate: ::RDF::URI.new("http://www.ebu.ch/metadata/ontologies/ebucore/ebucore#hasFormat"), multiple: false, index_to_parent: true do |index|
    index.as :stored_searchable
  end

  property :standard, predicate: ::RDF::URI.new("http://www.ebu.ch/metadata/ontologies/ebucore/ebucore#hasStandard"), multiple: false do |index|
    index.as :stored_searchable
  end

  property :location, predicate: ::RDF::URI.new("http://www.ebu.ch/metadata/ontologies/ebucore/ebucore#locator"), multiple: false do |index|
    index.as :stored_searchable
  end

  property :media_type, predicate: ::RDF::URI.new("http://purl.org/dc/terms/type"), multiple: false, index_to_parent: true do |index|
    index.as :stored_searchable, :facetable
  end

  property :generations, predicate: ::RDF::URI.new("http://www.ebu.ch/metadata/ontologies/ebucore/ebucore#hasGeneration"), multiple: true do |index|
    index.as :stored_searchable, :facetable
  end

  property :time_start, predicate: ::RDF::URI.new("http://www.ebu.ch/metadata/ontologies/ebucore/ebucore#start"), multiple: false do |index|
    index.as :stored_searchable
  end

  property :duration, predicate: ::RDF::URI.new("http://www.ebu.ch/metadata/ontologies/ebucore/ebucore#duration"), multiple: false do |index|
    index.as :stored_searchable
  end

  property :colors, predicate: ::RDF::URI.new("http://id.loc.gov/ontologies/bibframe.html#c_ColorContent"), multiple: false do |index|
    index.as :stored_searchable
  end

  property :rights_summary, predicate: ::RDF::URI.new("http://purl.org/dc/elements/1.1/rights"), multiple: true do |index|
    index.as :stored_searchable
  end

  property :rights_link, predicate: ::RDF::URI.new("http://www.europeana.eu/rights"), multiple: true do |index|
    index.as :stored_searchable
  end

  property :annotation, predicate: ::RDF::URI.new("http://www.w3.org/2004/02/skos/core#note"), multiple: true do |index|
    index.as :stored_searchable
  end

  property :local_instantiation_identifier, predicate: ::RDF::URI.new("http://pbcore.org#localInstantiationIdentifier"), multiple: true, index_to_parent: true do |index|
    index.as :stored_searchable
  end

  property :tracks, predicate: ::RDF::URI.new("http://pbcore.org#hasTracks"), multiple: false do |index|
    index.as :stored_searchable
  end

  property :channel_configuration, predicate: ::RDF::URI.new("http://pbcore.org#hasChannelConfiguration"), multiple: false do |index|
    index.as :stored_searchable
  end

  property :alternative_modes, predicate: ::RDF::URI.new("http://pbcore.org#hasAlternativeModes"), multiple: false do |index|
    index.as :stored_searchable
  end

  property :holding_organization, predicate: ::RDF::URI.new("http://pbcore.org#hasHoldingOrganization"), multiple: false, index_to_parent: true do |index|
    index.as :stored_searchable, :facetable
  end

  property :instantiation_admin_data_gid, predicate: ::RDF::URI.new('http://pbcore.org#hasInstantiationAdminData'), multiple: false do |index|
    index.as :symbol
  end



  def instantiation_admin_data_gid=(new_instantiation_admin_data_gid)
    raise "Can't modify admin data of this asset" if persisted? && !instantiation_admin_data_gid_was.nil? && instantiation_admin_data_gid_was != new_instantiation_admin_data_gid
    new_instantiation_admin_data = InstantiationAdminData.find_by_gid!(new_instantiation_admin_data_gid)
    super
    @instantiation_admin_data=new_instantiation_admin_data
    instantiation_admin_data_gid
  end

  def instantiation_admin_data
    @instantiation_admin_data_gid ||= InstantiationAdminData.find_by_gid(instantiation_admin_data_gid)
  end

  def instantiation_admin_data=(new_admin_data)
    self[:instantiation_admin_data_gid] = new_admin_data.gid
  end

  # This must be included at the end, because it finalizes the metadata if you have any further properties define above in current model
  include ::Hyrax::BasicMetadata

  private
  def find_or_create_instantiation_admin_data
    self.instantiation_admin_data ||= InstantiationAdminData.create
  end

  def save_instantiation_admin_data
    find_or_create_instantiation_admin_data
    self.instantiation_admin_data.save
  end
  # This must be included at the end, because it finalizes the metadata if you have any further properties define above in current model
  include ::Hyrax::BasicMetadata
end
