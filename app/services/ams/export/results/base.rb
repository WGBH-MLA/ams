module AMS
  module Export
    module Results
      class Base
        attr_reader :solr_documents
        def initialize(solr_documents:)
          @solr_documents = solr_documents
          write_to_file
        end

        def filepath
          "#{tmp_dir}/#{filename}"
        end

        def content_type
          raise "#{self.class}#content_type must be implemented to return " \
                "the value for HTTP header Content-type."
        end

        private

          def write_to_file
            raise "#{self.class}#write_to_file must be implemented to write " \
                  "results to file."
          end

          def filename
            raise "#{self.class}#filename must be implemented to return the " \
                  "export filename."
          end

          def timestamp
            @timestamp ||= Time.now.strftime('%Y-%m-%d_%H%M%S')
          end

          def tmp_dir
            @tmp_dir ||= Dir.mktmpdir
          end
      end
    end
  end
end
