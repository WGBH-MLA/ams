module SeriesMetadata
  extend ActiveSupport::Concern

  included do
    property :series_title, predicate: ::RDF::Vocab::DC.title, multiple: :true do |index|
      index.as :stored_searchable
    end

    property :series_description, predicate: ::RDF::Vocab::DC.description, multiple: :true do |index|
      index.as :stored_searchable
    end

    property :series_pbs_nola_code, predicate: ::RDF::Vocab::Bibframe.identifier, multiple: :true do |index|
      index.as :stored_searchable
    end

    property :series_start_date, predicate: ::RDF::Vocab::DC.date, multiple: :false do |index|
      index.as :stored_searchable
    end

    property :series_end_date, predicate: ::RDF::Vocab::DC.date, multiple: :false do |index|
      index.as :stored_searchable
    end

    property :series_eidr_id, predicate: ::RDF::Vocab::Identifiers.eidr, multiple: :true do |index|
      index.as :stored_searchable
    end

    property :series_annotation , predicate: ::RDF::Vocab::SKOS.note, multiple: :true do |index|
      index.as :stored_searchable
    end
  end
end
