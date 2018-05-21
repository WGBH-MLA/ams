# Define a module to prepend to Hyrax::Forms::ColectionForm Module#prepend to override methods from Hyrax::CollectionForm.
# Usage: Hyrax::Forms::CollectionForm.prepend SeriesCollectionFormOverrides
module SeriesCollectionFormOverrides
  def self.prepended(collection_form_class)
    raise "#{self.name} can only be prepended to ::Hyrax::Forms::CollectionForm" unless collection_form_class == ::Hyrax::Forms::CollectionForm
    # Mutate the collection_form_class
    collection_form_class.instance_eval do
      self.terms = [ :series_title, :series_description, :series_pbs_nola_code,
        :series_eidr_id, :series_start_date, :series_end_date, :series_annotation ]
    end
  end

  def required_fields
    [:series_title]
  end

  def primary_terms
    if self.class.ancestors.include? ::SeriesCollectionFormOverrides
        [
          :series_title,
          :series_description,
          :series_pbs_nola_code,
          :series_eidr_id,
          :series_start_date,
          :series_end_date,
          :series_annotation
        ]
    else
      super
    end
  end

  def secondary_terms
    []
  end

  delegate :series_title, :series_description, :series_pbs_nola_code,
          :series_eidr_id, :series_start_date, :series_end_date, :series_annotation, to: :model
end
