# frozen_string_literal: true
class SolrDocument
  include Blacklight::Solr::Document
  include Blacklight::Gallery::OpenseadragonSolrDocument
  include ::AMS::Solr::CreateMemberMethods

  # Adds Hyrax behaviors to the SolrDocument.
  include Hyrax::SolrDocumentBehavior

  # self.unique_key = 'id'

  # Email uses the semantic field mappings below to generate the body of an email.
  SolrDocument.use_extension(Blacklight::Document::Email)

  # SMS uses the semantic field mappings below to generate the body of an SMS email.
  SolrDocument.use_extension(Blacklight::Document::Sms)

  SolrDocument.use_extension(AMS::CsvExportExtension)
  SolrDocument.use_extension(AMS::PbcoreXmlExportExtension)

  # DublinCore uses the semantic field mappings below to assemble an OAI-compliant Dublin Core document
  # Semantic mappings of solr stored fields. Fields may be multi or
  # single valued. See Blacklight::Document::SemanticFields#field_semantics
  # and Blacklight::Document::SemanticFields#to_semantic_values
  # Recommendation: Use field names from Dublin Core
  use_extension(Blacklight::Document::DublinCore)

  # Do content negotiation for AF models.

  use_extension(Hydra::ContentNegotiation)

  # Determine which type of Fedora record this SolrDocument instance represents.
  def record_type
    self['has_model_ssim'].first
  end

  # Define boolean predicates for determining record type.
  def is_asset?; record_type == "Asset"; end
  def is_physical_instantiation?; record_type == "PhysicalInstantiation"; end
  def is_digital_instantiation?; record_type == "DigitalInstantiation"; end

  # Specific ID accessors based on record type.
  def asset_id; id if is_asset?; end
  def physical_instantiation_id; id if is_physical_instantiation?; end
  def digital_instantiation_id; id if is_digital_instantiation?; end

  # Returns an array of SolrDocument instances for members.
  # NOTE: This is not ideal to have the SolrDocument running additional Solr
  #   queries, but it's all we've got currently.
  def members
    # TODO: Use just one query to return all docs?
    Array(member_ids).map { |id| SolrDocument.find(id) }
  end

  def member_of
    self.class.repository.search("q" => "member_ids_ssim:#{id}")['response']['docs'].map do |doc|
      SolrDocument.new(doc)
    end
  end

  def parent_asset
    @parent_asset ||= member_of.detect { |parent| parent.is_asset? }
  end

  def parent_asset_id
    parent_asset.id
  end

  def physical_instantiations
    members.select { |member| member.is_physical_instantiation? }
  end

  def digital_instantiations
    members.select { |member| member.is_physical_instantiation? }
  end

  def asset_types
    self[Solrizer.solr_name('asset_types')]
  end

  def genre
    self[Solrizer.solr_name('genre')]
  end

  def episode_number
    self[Solrizer.solr_name('episode_number')]
  end

  def spatial_coverage
    self[Solrizer.solr_name('spatial_coverage')]
  end

  def temporal_coverage
    self[Solrizer.solr_name('temporal_coverage')]
  end

  def audience_level
    self[Solrizer.solr_name('audience_level')]
  end

  def audience_rating
    self[Solrizer.solr_name('audience_rating')]
  end

  def annotation
    self[Solrizer.solr_name('annotation')]
  end

  def rights_summary
    self[Solrizer.solr_name('rights_summary')]
  end

  def rights_link
    self[Solrizer.solr_name('rights_link')]
  end

  def digitization_date
    self[Solrizer.solr_name('digitization_date')]
  end

  def dimensions
    self[Solrizer.solr_name('dimensions')]
  end

  def format
    self[Solrizer.solr_name('format')]
  end

  def standard
    self[Solrizer.solr_name('standard')]
  end

  def location
    self[Solrizer.solr_name('location')]
  end

  def media_type
    self[Solrizer.solr_name('media_type')]
  end

  def generations
    self[Solrizer.solr_name('generations')]
  end

  def time_start
    self[Solrizer.solr_name('time_start')]
  end

  def duration
    self[Solrizer.solr_name('duration')]
  end

  def colors
    self[Solrizer.solr_name('colors')]
  end

  def language
    self[Solrizer.solr_name('language')]
  end

  def file_size
    self[Solrizer.solr_name('file_size')]
  end

  def data_rate
    self[Solrizer.solr_name('data_rate')]
  end

  def track_type
    self[Solrizer.solr_name('track_type')]
  end

  def track_id
    self[Solrizer.solr_name('track_id')]
  end

  def encoding
    self[Solrizer.solr_name('encoding')]
  end

  def frame_rate
    self[Solrizer.solr_name('frame_rate')]
  end

  def playback_speed
    self[Solrizer.solr_name('playback_speed')]
  end

  def playback_speed_units
    self[Solrizer.solr_name('playback_speed_units')]
  end

  def sample_rate
    self[Solrizer.solr_name('sample_rate')]
  end

  def bit_depth
    self[Solrizer.solr_name('bit_depth')]
  end

  def frame_width
    self[Solrizer.solr_name('frame_width')]
  end

  def frame_height
    self[Solrizer.solr_name('frame_height')]
  end

  def aspect_ratio
    self[Solrizer.solr_name('aspect_ratio')]
  end

  def contributor_role
    self[Solrizer.solr_name('contributor_role')]
  end

  def portrayal
    self[Solrizer.solr_name('portrayal')]
  end

  def digital_format
    self[Solrizer.solr_name('digital_format')]
  end

  def local_identifier
    self[Solrizer.solr_name('local_identifier')]
  end

  def pbs_nola_code
    self[Solrizer.solr_name('pbs_nola_code')]
  end

  def eidr_id
    self[Solrizer.solr_name('eidr_id')]
  end

  def topics
    self[Solrizer.solr_name('topics')]
  end

  def subject
    self[Solrizer.solr_name('subject')]
  end

  def local_instantiation_identifier
    self[Solrizer.solr_name('local_instantiation_identifier')]
  end

  def tracks
    self[Solrizer.solr_name('tracks')]
  end

  def channel_configuration
    self[Solrizer.solr_name('channel_configuration')]
  end

  def alternative_modes
    self[Solrizer.solr_name('alternative_modes')]
  end

  def title
    concatenated_titles = [series_title,
      program_title, episode_number, episode_title, segment_title, clip_title,
      promo_title, raw_footage_title,
      self[Solrizer.solr_name('title')]
    ].flatten.select(&:present?).join('; ')
    # Wrap the return value in an array to behave like a multi-valued field,
    # even though this will always be a single value.
    Array(concatenated_titles)
  end

  def series_title
    self[Solrizer.solr_name('series_title')]
  end

  def program_title
    self[Solrizer.solr_name('program_title')]
  end

  def episode_title
    self[Solrizer.solr_name('episode_title')]
  end

  def segment_title
    self[Solrizer.solr_name('segment_title')]
  end

  def raw_footage_title
    self[Solrizer.solr_name('raw_footage_title')]
  end

  def promo_title
    self[Solrizer.solr_name('promo_title')]
  end

  def clip_title
    self[Solrizer.solr_name('clip_title')]
  end

  def display_description
    description = [raw_footage_description, segment_description, clip_description, promo_description, episode_description, program_description, series_description, self[Solrizer.solr_name('description')]].find(&:present?)
    description.first.truncate(100, separator: ' ') unless description.nil?
  end

  def series_description
    self[Solrizer.solr_name('series_description')]
  end

  def program_description
    self[Solrizer.solr_name('program_description')]
  end

  def episode_description
    self[Solrizer.solr_name('episode_description')]
  end

  def segment_description
    self[Solrizer.solr_name('segment_description')]
  end

  def raw_footage_description
    self[Solrizer.solr_name('raw_footage_description')]
  end

  def promo_description
    self[Solrizer.solr_name('promo_description')]
  end

  def clip_description
    self[Solrizer.solr_name('clip_description')]
  end

  def all_dates
    [
      date,
      broadcast_date,
      created_date,
      copyright_date
    ].flatten.select(&:present?).join('; ')
  end

  # alias
  def dates; all_dates; end

  def display_dates
    { Solrizer.solr_name('date') => date,
      Solrizer.solr_name('broadcast_date') => broadcast_date,
      Solrizer.solr_name('created_date') => created_date,
      Solrizer.solr_name('copyright_date') => copyright_date
    }.select{ |k,v| v.present? }
  end

  def date
    self[Solrizer.solr_name('date')]
  end

  def broadcast_date
    self[Solrizer.solr_name('broadcast_date')]
  end

  def created_date
    self[Solrizer.solr_name('created_date')]
  end

  def copyright_date
    self[Solrizer.solr_name('copyright_date')]
  end

  def holding_organization
    self[Solrizer.solr_name('holding_organization')]
  end

  def holding_organization_ssim
    self[Solrizer.solr_name('holding_organization','ssim')]
  end

  def affiliation
    self[Solrizer.solr_name('affiliation')]
  end

  def producing_organization
    self[Solrizer.solr_name('producing_organization')]
  end

  def level_of_user_access
    self[Solrizer.solr_name('level_of_user_access', 'ssim')]
  end

  def outside_url
    self[Solrizer.solr_name('outside_url', 'ssim')]
  end

  def special_collections
    self[Solrizer.solr_name('special_collections', 'ssim')]
  end

  def transcript_status
    self[Solrizer.solr_name('transcript_status', 'ssim')]
  end

  def organization
    self[Solrizer.solr_name('organization', 'ssim')]
  end

  def sonyci_id
    self[Solrizer.solr_name('sonyci_id', 'ssim')]
  end

  def licensing_info
    self[Solrizer.solr_name('licensing_info', 'ssim')]
    end

  def playlist_group
    self[Solrizer.solr_name('playlist_group', 'ssim')]
  end

  def playlist_order
    self[Solrizer.solr_name('playlist_order', 'ssim')]
  end

  def media_src(part)
    "/media/#{id}?part=#{part.to_s}"
  end

  def digitized?
    sonyci_id.present?
  end

  def identifying_data
    { "id" => id, Solrizer.solr_name('admin_set') => admin_set }
  end

  def aapb_preservation_lto
    self[Solrizer.solr_name('aapb_preservation_lto')]
  end

  def aapb_preservation_disk
    self[Solrizer.solr_name('aapb_preservation_disk')]
  end

  def hyrax_batch_ingest_batch_id
    self[Solrizer.solr_name('hyrax_batch_ingest_batch_id')]
  end

  def last_pushed
    self[Solrizer.solr_name('last_pushed')]
  end

  def last_updated
    self[Solrizer.solr_name('last_updated')]
  end

  def needs_update
    self[Solrizer.solr_name('needs_update')]
  end

  def special_collection_category
    self[Solrizer.solr_name('special_collection_category', 'ssim')]
  end

  def canonical_meta_tag
    self[Solrizer.solr_name('canonical_meta_tag', 'ssim')]
  end

  def cataloging_status
    self[Solrizer.solr_name('cataloging_status', 'ssim')]
  end

  def captions_url
    self[Solrizer.solr_name('captions_url', 'ssim')]
  end

  def external_reference_url
    self[Solrizer.solr_name('external_reference_url','ssim')]
  end

  def last_modified
    self[Solrizer.solr_name('last_modified','ssim')]
  end

  def mavis_number
    self[Solrizer.solr_name('mavis_number','ssim')]
  end

  def project_code
    self[Solrizer.solr_name('project_code','ssim')]
  end

  def supplemental_material
    self[Solrizer.solr_name('supplemental_material','ssim')]
  end

  def transcript_url
    self[Solrizer.solr_name('transcript_url','ssim')]
  end

  def transcript_source
    self[Solrizer.solr_name('transcript_source','ssim')]
  end

  def md5
    # this nonsensical ':symbol' option indicates that I am selecting the _ssim suffix from down in solrizer - default was _tesim, which was wrong for this field
    self[Solrizer.solr_name('md5', :symbol)]
  end

  def all_nested_member_ids
    all_member_ids = self.member_ids.clone
    self.member_ids.each do |member_id|
      all_member_ids << get_members(member_id)
    end
    all_member_ids.flatten
  end

  private

  # Recursively get all members off of members
  def get_members(id)
    ids = []
    object = SolrDocument.find(id)
    object.member_ids.each do |member_id|
      ids << member_id
      SolrDocument.find(member_id).member_ids.each do |mem_id|
        get_members(mem_id)
      end
    end
    ids
  end

end
