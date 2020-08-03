require_relative '../../../app/services/ams/migrations/annotation_migration'

namespace :ams do
  desc 'Resets Fedora, Solr, Database, and creates default admin set'
  task :annotation_migration => :environment do
    AMS::Migrations::AnnotationMigration.new.run
  end
end
