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
      media_content = []
      if @solr_doc['media']
        @solr_doc['media'].each_with_index do |media,index|
          if media[:type] == "video"
            media_content << video_content(@solr_doc.media_src(index.to_s),
                                           width=media[:width].nil??400:media[:width], height=media[:height].nil??400:media[:height], duration=media[:duration])
          elsif media[:type] == "audio"
            media_content << audio_content(@solr_doc.media_src(index.to_s),
                                           duration=media[:duration])

          end
        end
      end
      media_content
    end

    def video_content(url,width,height,duration)
      IIIFManifest::V3::DisplayContent.new(url,
                                           label: self.to_s,
                                           width: Array(width).first.try(:to_i),
                                           height: Array(height).first.try(:to_i),
                                           duration: Array(duration).first.try(:to_i) / 1000.0,
                                           type: 'Video')
    end

    def audio_content(url,duration)
      IIIFManifest::V3::DisplayContent.new(url,
                                           label: self.to_s,
                                           duration: Array(duration).first.try(:to_i) / 1000.0,
                                           type: 'Sound')
    end

    def to_s
      solr_doc[:title].to_s
    end

    def range
      []
    end
  end
end