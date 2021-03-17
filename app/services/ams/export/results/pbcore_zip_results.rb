module AMS
  module Export
    module Results
      class PBCoreZipResults < Base

        def filename
          "export-assets-pbcore-#{timestamp}.zip"
        end

        def write_to_file
          tmpfiles = []
          Zip::File.open(filepath, Zip::File::CREATE) do |zip_file|
            solr_documents.each do |solr_doc|
              # Write PBCore XML to a tmpfile.
              tmpfiles << Tempfile.open { |f| f << solr_doc.export_as_pbcore }
              # Add tmpfile to the zip with a filename based on the ID.
              zip_file.add("#{solr_doc.id}.xml", tmpfiles.last.path)
            end
          end
          # Explicitly unlink all the tmpfiles created. Optional, but a best
          # practice to avoid having to wait on garbage collection.
          tmpfiles.each { |f| File.unlink(f.path) }
        end
      end
    end
  end
end
