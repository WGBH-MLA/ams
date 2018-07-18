require 'ams'

namespace :ams do
  desc 'Resets Fedora, Solr, Database, and creates default admin set'
  task reset_data: :environment do
    # Warn the user
    print "\nWARNING! All data from the #{Rails.env.upcase} environment will " \
          "be reset.\n\nDo you wish to proceed? (y/N) "

    # Require a 'y' or 'yes' confirmation from the user.
    answer = STDIN.gets.chomp.to_s.downcase
    unless ['y', 'yes'].include?(answer)
      print "\nQuitting without resetting data.\n\n"
      exit
    end

    # NOTE: The Fedora and Solr must already be running.
    AMS.logger.level = Logger::INFO
    AMS.reset_data!
  end
end
