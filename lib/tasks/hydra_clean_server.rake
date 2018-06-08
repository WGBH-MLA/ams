require 'solr_wrapper/rake_task' unless Rails.env.production?
require 'fcrepo_wrapper/rake_task' unless Rails.env.production?
require 'active_fedora/cleaner'

namespace :hydra do
  namespace :clean do
    desc 'Resets Fedora, Solr, Database, and creates default admin set'
    task :server do
      ENV['RAILS_ENV'] ||= 'development'
      Rake::Task['db:reset'].invoke
      puts "\nStarting Solr and Fedora in order to delete all the data therein..."
      begin
        with_server(ENV['RAILS_ENV']) do
          puts "\nCleaning fedora with ActiveFedora::Cleaner.clean!..."
          ActiveFedora::Cleaner.clean!
          puts "\nCreating the default admin set..."
          Rake::Task['hyrax:default_admin_set:create'].invoke
        end
      rescue EOFError => e
        # FcrepoWrapper::Instance#status throws an EOFError due to a patched
        # version of Net::HTTP#transport_request that is introduced by aws-
        # sdk-core. However, the error is thrown just as FcrepoWrapper is
        # trying to stop Fedora and repeatedly checks the status for false.
        # So unless EOFError is getting thrown from somewhere else, we should
        # be OK just returning false here, because Fedora has already shut down
        # and there's nothing left to do.
        false
      end
      puts "Seeding the database"
      Rake::Task['db:seed'].invoke
    end

    desc 'Resets Fedora, Solr, Database, and creates default admin set for test environment'
    task :test_server do
      ENV['RAILS_ENV'] = 'test'
      Rake::Task['hydra:clean:server'].invoke
    end
  end
end
