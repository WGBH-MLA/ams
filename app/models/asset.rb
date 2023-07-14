class Asset < ActiveFedora::Base
  include ::Hyrax::WorkBehavior
  include ::AMS::CreateMemberMethods
  include ::AMS::IdentifierService
  include ::AMS::CascadeDestroyMembers
  include ::AMS::AllMembers

  self.indexer = AssetIndexer
  before_save :save_admin_data
  # Change this to restrict which works can be added as a child.
  self.valid_child_concerns = [DigitalInstantiation, PhysicalInstantiation, Contribution]

  # validate :at_least_one_title
  # validate :at_least_one_description
  validates_each :date, :broadcast_date, :created_date, :copyright_date,  allow_blank: true do |record, attr, value|
    value.each { |val|  record.errors.add(attr, "invalid date format: #{val}") if AMS::NonExactDateService.invalid?(val) }
  end

  after_destroy do
    admin_data.destroy if admin_data_gid
  end

  def at_least_one_title
    all_titles = title.to_a
    all_titles += program_title.to_a
    all_titles += episode_title.to_a
    all_titles += segment_title.to_a
    all_titles += clip_title.to_a
    all_titles += promo_title.to_a
    all_titles += raw_footage_title.to_a
    if all_titles.empty?
      errors.add :title, "cannot be empty"
    end
  end

  def at_least_one_description
    all_descriptions = description.to_a
    all_descriptions += program_description.to_a
    all_descriptions += episode_description.to_a
    all_descriptions += segment_description.to_a
    all_descriptions += clip_description.to_a
    all_descriptions += promo_description.to_a
    all_descriptions += raw_footage_description.to_a
    if all_descriptions.empty?
      errors.add :description, "cannot be empty"
    end
  end

  def admin_data
    @admin_data ||= AdminData.find_by_gid(admin_data_gid)
  end

  def admin_data=(new_admin_data)
    self[:admin_data_gid] = new_admin_data.gid
  end

  def annotations
    @annotations ||= admin_data.annotations
  end

  # TODO: Use RDF::Vocab for applicable terms.
  # See https://github.com/ruby-rdf/rdf-vocab/tree/develop/lib/rdf/vocab
  property :bulkrax_identifier, predicate: ::RDF::URI("http://ams2.wgbh-mla.org/resource#bulkraxIdentifier"), multiple: false do |index|
    index.as :stored_searchable, :facetable
  end

  property :asset_types, predicate: ::RDF::URI.new("http://www.ebu.ch/metadata/ontologies/ebucore/ebucore#hasType"), multiple: true do |index|
    index.as :stored_searchable, :facetable
  end

  property :genre, predicate: ::RDF::URI.new("http://www.ebu.ch/metadata/ontologies/ebucore/ebucore#hasGenre"), multiple: true do |index|
    index.as :stored_searchable, :facetable
  end

  property :date, predicate: ::RDF::URI.new("http://purl.org/dc/terms/date"), multiple: true do |index|
    index.as :stored_searchable, :facetable
  end

  property :broadcast_date, predicate: ::RDF::URI.new('http://pbcore.org#hasBroadcastDate'), multiple: :true do |index|
    index.as :stored_searchable
  end

  property :created_date, predicate: ::RDF::URI.new('http://pbcore.org#hasCreatedDate'), multiple: :true do |index|
    index.as :stored_searchable
  end

  property :copyright_date, predicate: ::RDF::URI.new('http://pbcore.org#hasCopyrightDate'), multiple: :true do |index|
    index.as :stored_searchable
  end

  property :episode_number, predicate: ::RDF::URI.new("http://www.ebu.ch/metadata/ontologies/ebucore/ebucore#episodeNumber"), multiple: true do |index|
    index.as :stored_searchable
  end

  property :spatial_coverage, predicate: ::RDF::Vocab::DC.coverage, multiple: true do |index|
    index.as :stored_searchable
  end

  property :temporal_coverage, predicate: ::RDF::URI.new("http://id.loc.gov/ontologies/bibframe.html#p_temporalCoverage"), multiple: true do |index|
    index.as :stored_searchable
  end

  property :audience_level, predicate: ::RDF::URI.new("http://www.ebu.ch/metadata/ontologies/ebucore/ebucore#hasTargetAudience"), multiple: true do |index|
    index.as :stored_searchable
  end

  property :audience_rating, predicate: ::RDF::URI.new("https://www.ebu.ch/metadata/ontologies/ebucore/index.html#Type"), multiple: true do |index|
    index.as :stored_searchable
  end

  property :annotation, predicate: ::RDF::URI.new("http://www.w3.org/2004/02/skos/core#note"), multiple: true do |index|
    index.as :stored_searchable
  end

  property :rights_summary, predicate: ::RDF::URI.new("http://purl.org/dc/elements/1.1/rights"), multiple: true do |index|
    index.as :stored_searchable
  end

  property :rights_link, predicate: ::RDF::URI.new("http://www.europeana.eu/rights"), multiple: true do |index|
    index.as :stored_searchable
  end

  property :local_identifier, predicate: ::RDF::URI.new("http://id.loc.gov/vocabulary/identifiers/local"), multiple: true do |index|
    index.as :stored_searchable
  end

  property :pbs_nola_code, predicate: ::RDF::Vocab::EBUCore.hasIdentifier, multiple: true do |index|
    index.as :stored_searchable
  end

  property :eidr_id, predicate: ::RDF::URI.new("https://www.w3.org/2002/07/owl#sameAs"), multiple: true do |index|
    index.as :stored_searchable
  end

  property :topics, predicate: ::RDF::URI.new("http://www.ebu.ch/metadata/ontologies/ebucore/ebucore#hasKeyword"), multiple: true do |index|
    index.as :stored_searchable, :facetable
  end

  property :subject, predicate: ::RDF::URI.new("http://purl.org/dc/elements/1.1/subject"), multiple: true do |index|
    index.as :stored_searchable
  end

  property :program_title, predicate: ::RDF::URI.new('http://pbcore.org#hasProgramTitle'), multiple: :true do |index|
    index.as :stored_searchable
  end

  property :episode_title, predicate: ::RDF::URI.new('http://pbcore.org#hasEpisodeTitle'), multiple: :true do |index|
    index.as :stored_searchable
  end

  property :segment_title, predicate: ::RDF::URI.new('http://pbcore.org#hasSegmentTitle'), multiple: :true do |index|
    index.as :stored_searchable
  end

  property :raw_footage_title, predicate: ::RDF::URI.new('http://pbcore.org#hasRawFootageTitle'), multiple: :true do |index|
    index.as :stored_searchable
  end

  property :promo_title, predicate: ::RDF::URI.new('http://pbcore.org#hasPromoTitle'), multiple: :true do |index|
    index.as :stored_searchable
  end

  property :clip_title, predicate: ::RDF::URI.new('http://pbcore.org#hasClipTitle'), multiple: :true do |index|
    index.as :stored_searchable
  end

  property :program_description, predicate: ::RDF::URI.new('http://pbcore.org#hasProgramDescription'), multiple: :true do |index|
    index.as :stored_searchable
  end

  property :episode_description, predicate: ::RDF::URI.new('http://pbcore.org#hasEpisodeDescription'), multiple: :true do |index|
    index.as :stored_searchable
  end

  property :segment_description, predicate: ::RDF::URI.new('http://pbcore.org#hasSegmentDescription'), multiple: :true do |index|
    index.as :stored_searchable
  end

  property :raw_footage_description, predicate: ::RDF::URI.new('http://pbcore.org#hasRawFootageDescription'), multiple: :true do |index|
    index.as :stored_searchable
  end

  property :promo_description, predicate: ::RDF::URI.new('http://pbcore.org#hasPromoDescription'), multiple: :true do |index|
    index.as :stored_searchable
  end

  property :clip_description, predicate: ::RDF::URI.new('http://pbcore.org#hasClipDescription'), multiple: :true do |index|
    index.as :stored_searchable
  end

  property :producing_organization, predicate: ::RDF::URI.new("http://purl.org/dc/elements/1.1/creator"), multiple: true do |index|
    index.as :stored_searchable, :facetable
  end

  property :admin_data_gid, predicate: ::RDF::URI.new('http://pbcore.org#hasAAPBAdminData'), multiple: false do |index|
    index.as :symbol
  end

  property :series_title, predicate: ::RDF::URI.new('http://pbcore.org#hasSeriesTitle'), multiple: :true do |index|
    index.as :stored_searchable
  end

  property :series_description, predicate: ::RDF::URI.new('http://pbcore.org#hasSeriesDescription'), multiple: :true do |index|
    index.as :stored_searchable
  end

  # This property is intended to be an Integer, but ActiveFedora stores everything as Strings. We don't declare indexing
  # rules in a block here because indexing for this property is handled manually.
  # @see AssetIndexer#generate_solr_document
  property :intended_children_count, predicate: ::RDF::URI("http://ams2.wgbh-mla.org/resource#intendedChildrenCount"), multiple: false

  property :aapb_pushable, predicate: ::RDF::URI("http://ams2.wgbh-mla.org/terms/aapbPushable"), multiple: false do |index|
    index.type :boolean
    index.as :stored_searchable
  end

  def admin_data_gid=(new_admin_data_gid)
    raise "Can't modify admin data of this asset" if persisted? && !admin_data_gid_was.nil? && admin_data_gid_was != new_admin_data_gid
    new_admin_data = AdminData.find_by_gid!(new_admin_data_gid)
    # TODO: what is the `super` call for? There's no amdin_data_gid= method in
    # any ancestor afaik, but double check.
    super
    @admin_data=new_admin_data
    admin_data_gid
  end

  def admin_data_gid_document_field_name
    Solrizer.solr_name('admin_data_gid', *index_admin_data_gid_as)
  end

  def sonyci_id
    sonyci_id ||= find_admin_data_attribute("sonyci_id")
  end

  def supplemental_material
    supplemental_material ||= find_annotation_attribute("supplemental_material")
  end

  def organization
    organization ||= find_annotation_attribute("organization")
  end

  def level_of_user_access
    level_of_user_access ||= find_annotation_attribute("level_of_user_access")
  end

  def transcript_status
    transcript_status ||= find_annotation_attribute("transcript_status")
  end

  def transcript_url
    transcript_url ||= find_annotation_attribute("transcript_url")
  end

  def transcript_source
    transcript_source ||= find_annotation_attribute("transcript_source")
  end

  def cataloging_status
    cataloging_status ||= find_annotation_attribute("cataloging_status")
  end

  def captions_url
    captions_url ||= find_annotation_attribute("captions_url")
  end

  def last_modified
    licensing_info ||= find_annotation_attribute("last_modified")
  end

  def licensing_info
    licensing_info ||= find_annotation_attribute("licensing_info")
  end

  def outside_url
    outside_url ||= find_annotation_attribute("outside_url")
  end

  def external_reference_url
    external_reference_url ||= find_annotation_attribute("external_reference_url")
  end

  def mavis_number
    mavis_number ||= find_annotation_attribute("mavis_number")
  end

  def playlist_group
    playlist_group ||= find_annotation_attribute("playlist_group")
  end

  def playlist_order
    playlist_order ||= find_annotation_attribute("playlist_order")
  end

  def special_collections
    special_collection ||= find_annotation_attribute("special_collections")
  end

  def special_collection_category
    special_collection_category ||= find_annotation_attribute("special_collection_category")
  end

  def project_code
    project_code ||= find_annotation_attribute("project_code")
  end

  def canonical_meta_tag
    canonical_meta_tag ||= find_annotation_attribute("canonical_meta_tag")
  end

  def proxy_start_time
    proxy_start_time ||= find_annotation_attribute("proxy_start_time")
  end

  def find_annotation_attribute(attribute)
    if admin_data.annotations.select { |a| a.annotation_type == attribute }.present?
      return admin_data.annotations.select { |a| a.annotation_type == attribute }.map(&:value)
    else
      []
    end
  end

  def find_admin_data_attribute(attribute)
    if admin_data.try(attribute.to_sym).present?
      return [ admin_data.try(attribute.to_sym) ] unless admin_data.try(attribute.to_sym).is_a?(Array)
      return admin_data.try(attribute.to_sym)
    else
      []
    end
  end

  # This must be included at the end, because it finalizes the metadata if you have any further properties define above in current model
  include ::Hyrax::BasicMetadata

  private
    def save_admin_data
      self.admin_data ||= AdminData.create
      self.admin_data.save
      self.admin_data_gid = self.admin_data.gid
    end
end
