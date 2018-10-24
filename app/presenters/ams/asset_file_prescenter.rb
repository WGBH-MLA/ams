module AMS
  class AssetFilePrescenter
    attr_accessor :solr_doc

    def initialize(solr_doc)
      @solr_doc = solr_doc
    end

    def id
      solr_doc[:id]
    end

    def display_content
      [video_content,video_content]
    end

    def video_content
      IIIFManifest::V3::DisplayContent.new("http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4",
                                           label: "asdasd",
                                           width: Array(400).first.try(:to_i),
                                           height: Array(250).first.try(:to_i),
                                           duration: Array(60).first.try(:to_i) / 1000.0,
                                           type: 'Video')
    end

    def to_s
      solr_doc[:title].to_s
    end

    def range
      []
    end
  end
end