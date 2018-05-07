# frozen_string_literal: true
class SolrDocument
  include Blacklight::Solr::Document
  include Blacklight::Gallery::OpenseadragonSolrDocument

  # Adds Hyrax behaviors to the SolrDocument.
  include Hyrax::SolrDocumentBehavior

  # self.unique_key = 'id'

  # Email uses the semantic field mappings below to generate the body of an email.
  SolrDocument.use_extension(Blacklight::Document::Email)

  # SMS uses the semantic field mappings below to generate the body of an SMS email.
  SolrDocument.use_extension(Blacklight::Document::Sms)

  # DublinCore uses the semantic field mappings below to assemble an OAI-compliant Dublin Core document
  # Semantic mappings of solr stored fields. Fields may be multi or
  # single valued. See Blacklight::Document::SemanticFields#field_semantics
  # and Blacklight::Document::SemanticFields#to_semantic_values
  # Recommendation: Use field names from Dublin Core
  use_extension(Blacklight::Document::DublinCore)

  # Do content negotiation for AF models.

  use_extension(Hydra::ContentNegotiation)

  def asset_types
    self[Solrizer.solr_name('asset_types')]
  end

  def genre
    self[Solrizer.solr_name('genre')]
  end

  def broadcast
    self[Solrizer.solr_name('broadcast')]
  end

  def date
    self[Solrizer.solr_name('date')]
  end

  def created
    self[Solrizer.solr_name('created')]
  end

  def copyright_date
    self[Solrizer.solr_name('copyright_date')]
  end

  def episode_number
    self[Solrizer.solr_name('episode_number')]
  end

  def description
    self[Solrizer.solr_name('description')]
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

  def playback_inch_per_sec
    self[Solrizer.solr_name('playback_inch_per_sec')]
  end

  def playback_frame_per_sec
    self[Solrizer.solr_name('playback_frame_per_sec')]
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
    self[Solrizer.solr_name('frame_hight')]
  end
  
  def aspect_ratio
    self[Solrizer.solr_name('aspect_ratio')]
  end

  def contributor_role
    self[Solrizer.solr_name('contributor_role')]
  end

  def portrayal
    self[Solrizer.solr_name('portrayal')]

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

  def local_instantiation_identifer
    self[Solrizer.solr_name('local_instantiation_identifer')]
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
end
