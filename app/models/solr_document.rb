# frozen_string_literal: true
class SolrDocument
  include Blacklight::Solr::Document
  include Blacklight::Gallery::OpenseadragonSolrDocument

  # Adds Hyrax behaviors to the SolrDocument.
  include Hyrax::SolrDocumentBehavior

  include SolrHelper

  # self.unique_key = 'id'

  # Email uses the semantic field mappings below to generate the body of an email.
  SolrDocument.use_extension(Blacklight::Document::Email)

  # SMS uses the semantic field mappings below to generate the body of an SMS email.
  SolrDocument.use_extension(Blacklight::Document::Sms)

  SolrDocument.use_extension(AMS::CsvExportExtension)
  SolrDocument.use_extension(AMS::PbcoreXmlExportExtension)

  attribute :intended_children_count, Solr::String, 'intended_children_count_isi'
  attribute :validation_status_for_aapb, Solr::Array, 'validation_status_for_aapb_tesim'

  # DublinCore uses the semantic field mappings below to assemble an OAI-compliant Dublin Core document
  # Semantic mappings of solr stored fields. Fields may be multi or
  # single valued. See Blacklight::Document::SemanticFields#field_semantics
  # and Blacklight::Document::SemanticFields#to_semantic_values
  # Recommendation: Use field names from Dublin Core
  use_extension(Blacklight::Document::DublinCore)

  # Do content negotiation for AF models.

  use_extension(Hydra::ContentNegotiation)

  # Determine which type of Fedora record this SolrDocument instance represents.
  def has_model
    self['has_model_ssim'].first
  end

  # Define boolean predicates for determining record type.
  def is_asset?; has_model == "Asset"; end
  def is_physical_instantiation?; has_model == "PhysicalInstantiation"; end
  def is_digital_instantiation?; has_model == "DigitalInstantiation"; end
  def is_instantiation?; is_digital_instantiations || is_physical_instantiation; end

  # Specific ID accessors based on record type.
  def asset_id; id if is_asset?; end
  def physical_instantiation_id; id if is_physical_instantiation?; end
  def digital_instantiation_id; id if is_digital_instantiation?; end

  # Returns an array of SolrDocument instances for members.
  # NOTE: This is not ideal to have the SolrDocument running additional Solr
  #   queries, but it's all we've got currently.
  def members(only: [], except: [])
    return [] if member_ids.empty?

    @members ||= self.class.repository.search(q: "+id:(#{member_ids.join(' OR ')})", rows: 99999)['response']['docs'].map do |doc|
      SolrDocument.new(doc)
    end

    # Return only those where #has_model is in :only, if present.
    # Exclude any whose #has_model is in :exclude.
    only, except = Array(only).map(&:to_s), Array(except).map(&:to_s)
    @members.select { |m| only.empty? || only.include?(m.has_model) }.
             reject { |m| except.include?(m.has_model) }
  end

  def member_of
    self.class.repository.search(q: "member_ids_ssim:#{id}", rows: 99999)['response']['docs'].map do |doc|
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
    members only: [PhysicalInstantiation, PhysicalInstantiationResource]
  end

  def digital_instantiations
    members only: [DigitalInstantiation, DigitalInstantiationResource]
  end

  def asset_types
    self[solr_name('asset_types')]
  end

  def bulkrax_identifier
    self[solr_name('bulkrax_identifier')]
  end

  def genre
    self[solr_name('genre')]
  end

  def episode_number
    self[solr_name('episode_number')]
  end

  def spatial_coverage
    self[solr_name('spatial_coverage')]
  end

  def temporal_coverage
    self[solr_name('temporal_coverage')]
  end

  def audience_level
    self[solr_name('audience_level')]
  end

  def audience_rating
    self[solr_name('audience_rating')]
  end

  def annotation
    self[solr_name('annotation')]
  end

  def rights_summary
    self[solr_name('rights_summary')]
  end

  def rights_link
    self[solr_name('rights_link')]
  end

  def digitization_date
    self[solr_name('digitization_date')]
  end

  def dimensions
    self[solr_name('dimensions')]
  end

  def format
    self[solr_name('format')]
  end

  def standard
    self[solr_name('standard')]
  end

  def location
    self[solr_name('location')]
  end

  def media_type
    self[solr_name('media_type')]
  end

  def generations
    self[solr_name('generations')]
  end

  def time_start
    self[solr_name('time_start')]
  end

  def duration
    self[solr_name('duration')]
  end

  def colors
    self[solr_name('colors')]
  end

  def language
    self[solr_name('language')]
  end

  def file_size
    self[solr_name('file_size')]
  end

  def data_rate
    self[solr_name('data_rate')]
  end

  def track_type
    self[solr_name('track_type')]
  end

  def track_id
    self[solr_name('track_id')]
  end

  def encoding
    self[solr_name('encoding')]
  end

  def frame_rate
    self[solr_name('frame_rate')]
  end

  def playback_speed
    self[solr_name('playback_speed')]
  end

  def playback_speed_units
    self[solr_name('playback_speed_units')]
  end

  def sample_rate
    self[solr_name('sample_rate')]
  end

  def bit_depth
    self[solr_name('bit_depth')]
  end

  def frame_width
    self[solr_name('frame_width')]
  end

  def frame_height
    self[solr_name('frame_height')]
  end

  def aspect_ratio
    self[solr_name('aspect_ratio')]
  end

  def contributor_role
    self[solr_name('contributor_role')]
  end

  def portrayal
    self[solr_name('portrayal')]
  end

  def digital_format
    self[solr_name('digital_format')]
  end

  def local_identifier
    self[solr_name('local_identifier')]
  end

  def pbs_nola_code
    self[solr_name('pbs_nola_code')]
  end

  def eidr_id
    self[solr_name('eidr_id')]
  end

  def topics
    self[solr_name('topics')]
  end

  def subject
    self[solr_name('subject')]
  end

  def local_instantiation_identifier
    self[solr_name('local_instantiation_identifier')]
  end

  def tracks
    self[solr_name('tracks')]
  end

  def channel_configuration
    self[solr_name('channel_configuration')]
  end

  def alternative_modes
    self[solr_name('alternative_modes')]
  end

  def title
    concatenated_titles = [series_title,
      program_title, episode_number, episode_title, segment_title, clip_title,
      promo_title, raw_footage_title,
      self[solr_name('title')]
    ].flatten.select(&:present?).join('; ')
    # Wrap the return value in an array to behave like a multi-valued field,
    # even though this will always be a single value.
    Array(concatenated_titles)
  end

  def series_title
    self[solr_name('series_title')]
  end

  def program_title
    self[solr_name('program_title')]
  end

  def episode_title
    self[solr_name('episode_title')]
  end

  def segment_title
    self[solr_name('segment_title')]
  end

  def raw_footage_title
    self[solr_name('raw_footage_title')]
  end

  def promo_title
    self[solr_name('promo_title')]
  end

  def clip_title
    self[solr_name('clip_title')]
  end

  def display_description
    description = [raw_footage_description, segment_description, clip_description, promo_description, episode_description, program_description, series_description, self[solr_name('description')]].find(&:present?)
    description.first.truncate(100, separator: ' ') unless description.nil?
  end

  def series_description
    self[solr_name('series_description')]
  end

  def program_description
    self[solr_name('program_description')]
  end

  def episode_description
    self[solr_name('episode_description')]
  end

  def segment_description
    self[solr_name('segment_description')]
  end

  def raw_footage_description
    self[solr_name('raw_footage_description')]
  end

  def promo_description
    self[solr_name('promo_description')]
  end

  def clip_description
    self[solr_name('clip_description')]
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
    { solr_name('date') => date,
      solr_name('broadcast_date') => broadcast_date,
      solr_name('created_date') => created_date,
      solr_name('copyright_date') => copyright_date
    }.select{ |k,v| v.present? }
  end

  def date
    self[solr_name('date')]
  end

  def broadcast_date
    self[solr_name('broadcast_date')]
  end

  def created_date
    self[solr_name('created_date')]
  end

  def copyright_date
    self[solr_name('copyright_date')]
  end

  def holding_organization
    self[solr_name('holding_organization')]
  end

  def holding_organization_ssim
    self[solr_name('holding_organization', :symbol)]
  end

  def affiliation
    self[solr_name('affiliation')]
  end

  def producing_organization
    self[solr_name('producing_organization')]
  end

  def level_of_user_access
    self[solr_name('level_of_user_access', :symbol)]
  end

  def outside_url
    self[solr_name('outside_url', :symbol)]
  end

  def special_collections
    self[solr_name('special_collections', :symbol)]
  end

  def transcript_status
    self[solr_name('transcript_status', :symbol)]
  end

  def organization
    self[solr_name('organization', :symbol)]
  end

  def sonyci_id
    self[solr_name('sonyci_id', :symbol)]
  end

  def licensing_info
    self[solr_name('licensing_info', :symbol)]
    end

  def playlist_group
    self[solr_name('playlist_group', :symbol)]
  end

  def playlist_order
    self[solr_name('playlist_order', :symbol)]
  end

  def media_src(part)
    "/media/#{id}?part=#{part.to_s}"
  end

  def digitized?
    sonyci_id.present?
  end

  def identifying_data
    { "id" => id, solr_name('admin_set') => admin_set }
  end

  def aapb_preservation_lto
    self[solr_name('aapb_preservation_lto')]
  end

  def aapb_preservation_disk
    self[solr_name('aapb_preservation_disk')]
  end

  def bulkrax_importer_id
    self[solr_name('bulkrax_importer_id')]
  end

  def hyrax_batch_ingest_batch_id
    self[solr_name('hyrax_batch_ingest_batch_id')]
  end

  def last_pushed
    self[solr_name('last_pushed')]
  end

  def last_updated
    self[solr_name('last_updated')]
  end

  def needs_update
    self[solr_name('needs_update')]
  end

  def special_collection_category
    self[solr_name('special_collection_category', :symbol)]
  end

  def canonical_meta_tag
    self[solr_name('canonical_meta_tag', :symbol)]
  end

  def cataloging_status
    self[solr_name('cataloging_status', :symbol)]
  end

  def captions_url
    self[solr_name('captions_url', :symbol)]
  end

  def external_reference_url
    self[solr_name('external_reference_url', :symbol)]
  end

  def last_modified
    self[solr_name('last_modified', :symbol)]
  end

  def mavis_number
    self[solr_name('mavis_number', :symbol)]
  end

  def project_code
    self[solr_name('project_code', :symbol)]
  end

  def supplemental_material
    self[solr_name('supplemental_material', :symbol)]
  end

  def transcript_url
    self[solr_name('transcript_url', :symbol)]
  end

  def transcript_source
    self[solr_name('transcript_source', :symbol)]
  end

  def md5
    # this nonsensical ':symbol' option indicates that I am selecting the _ssim suffix from down in solrizer - default was _tesim, which was wrong for this field
    self[solr_name('md5', :symbol)]
  end

  def proxy_start_time
    self[solr_name('proxy_start_time', :symbol)]
  end

  def all_members(only: [], exclude: [])
    # Fetch members recursively and memoize. Subtract self from the list.
    @all_members ||= SolrDocument.get_members(self) - [ self ]

    # Filter @all_members with the :only and :except params
    only, except = Array(only).map(&:to_s), Array(except).map(&:to_s)
    @all_members.select { |m| only.empty? || only.include?(m.has_model) }.
                 reject { |m| except.include?(m.has_model) }
  end

  def admin_data_gid
    return unless is_asset?
    self['admin_data_gid_ssim'].first
  end

  def admin_data
    return unless is_asset?
    @admin_data ||= AdminData.find_by_gid(admin_data_gid)
  end

  def annotations
    return unless is_asset?
    @annotations ||= admin_data&.annotations
  end

  def instantiation_admin_data_gid
    return unless is_instantiation?
    @instantiation_admin_data_gid ||= self['admin_data_gid_ssim'].first
  end

  def instantiation_admin_data
    return unless is_instantiation?
    @instiation_admin_data ||= InstantiationAdminData.find_by_gid(instantiation_admin_data_gid)
  end

  ###
  # CLASS METHODS
  ###

  # Recursively get all members
  def self.get_members(doc)
    [ doc ] + doc.members.map { |member| get_members(member) }.flatten
  end
end
