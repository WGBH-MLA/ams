module AMS
  class << self
    # Accessor for logger used by AMS
    def logger
      @logger ||= Logger.new(STDOUT).tap do |logger|
        # Simplify the formatter to just be the message with newlines.
        logger.formatter = -> (_severity, _datetime, _progname, msg) { "\n#{msg}\n" }
        logger.level = Logger::WARN
      end
    end

    def reset_data!
      ensure_fedora_is_working
      clean_database!
      seed_database!
      clean_solr_and_fedora!
      seed_solr_and_fedora!
    end

    private

      def fedora_status
        response = ActiveFedora.fedora.connection.head(ActiveFedora.fedora.base_uri)
        response.response.status.to_i
      rescue
        nil
      end

      def ensure_fedora_is_working
        r = fedora_status
        if r == nil
          raise "Fedora must be running"
        elsif !r.between?(200,399)
          raise "Fedora is not working properly, and is returning an HTTP status of #{fedora_status}"
        end
      end

      def clean_database!
        require 'database_cleaner'
        DatabaseCleaner.clean_with :truncation
      end

      def seed_database!
        require 'rake'
        Rails.application.load_tasks unless Rake::Task.task_defined? 'db:seed'
        Rake::Task['db:seed'].invoke
      end

      def clean_solr_and_fedora!
        require 'active_fedora/cleaner'
        ActiveFedora::Cleaner.clean!
      end

      def seed_solr_and_fedora!
        AdminSet.find_or_create_default_admin_set_id
      end
  end
end
