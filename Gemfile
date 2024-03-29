source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

plugin 'bootboot', '~> 0.2.1'

if ENV['DEPENDENCIES_NEXT'] && !ENV['DEPENDENCIES_NEXT'].empty?

else
  gem 'rails', '~> 6.0'
  gem 'hyrax-batch_ingest', git: 'https://github.com/samvera-labs/hyrax-batch_ingest', branch: 'valkyrie_update'
  gem 'hyrax', github: 'samvera/hyrax', branch: 'double_combo_gbh_version' # , tag: 'hyrax-v5.0.0.rc1'
  # Use SCSS for stylesheets
  gem 'sass-rails', '~> 6.0'
  gem 'bootstrap', '~> 4.0'
  gem 'sony_ci_api', github: 'WGBH-MLA/sony_ci_api_rewrite', branch: 'main'
  gem 'hydra-role-management', '1.1.0'
  gem 'blacklight', '~> 7.29'
  gem 'blacklight_advanced_search', '7.0'
  gem 'twitter-typeahead-rails', '0.11.1.pre.corejavascript'
  # our custom changes require us to lock in the version of bulkrax
  gem 'bulkrax', git: 'https://github.com/samvera-labs/bulkrax.git', branch: 'hyrax-4-valkyrie-support'
  gem 'sidekiq', '~> 6.5.10'
end

# ebnf 2.5 causes rdf and linkeddata to get very old versions'
gem 'ebnf', '2.4.0'

gem 'dotenv-rails'
# Use Puma as the app server
gem 'puma', '~> 5.6'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.2'
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks', '~> 5'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.5'

# Use Redis adapter to run Action Cable in production
gem 'redis', '~> 4.0'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

group :development, :test do
  # Use sqlite3 as the database for Active Record
  # gem 'sqlite3', '1.3.13'
  gem 'capybara-screenshot'
  gem 'rspec', "~> 3.7"
  gem 'rspec-rails', "~> 3.7"
  gem 'rspec-activemodel-mocks'
  gem 'rspec-its'
  gem 'factory_bot_rails', '~> 4.0'
  gem 'shoulda-matchers'
  gem 'bixby' # bixby == the hydra community's rubocop rules
  gem 'webdrivers', '~> 4.0'
  gem 'capybara', '~> 3.0'
  gem 'selenium-webdriver'
  gem 'fcrepo_wrapper'
  gem 'solr_wrapper', '~> 2.1'
  gem 'webmock', '~> 3.7'
  gem 'rails-controller-testing'
  gem 'rspec_junit_formatter'
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '>= 3.0.5', '< 3.2'
  # NOTE: Spring was intentionally removed because it's suspected of causing
  # issues with concurrent job processing using Sidekiq. This could be a red
  # herring, but we're leaving it out for now, until we have more time to debug.
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  # gem 'spring'
  # gem 'spring-watcher-listen', '~> 2.0.0'
  gem "letter_opener"
  gem 'faker', '~> 3.0'
  # gem 'xray-rails' # should be commented out when actively using sidekiq.
end

gem 'rsolr', '>= 1.0'
gem 'jquery-rails'
gem 'devise'
gem 'devise-guests', '~> 0.6'
gem 'simple_form', '~> 5.1.0'
gem 'aws-sdk-s3'
gem 'aws-sdk-codedeploy'
gem 'carrierwave', '~> 1.3'
gem 'mysql2', '~> 0.5.3'
gem 'pg'
gem 'nokogiri'
gem 'bootstrap-multiselect-rails'
gem 'pbcore', github: 'scientist-softserv/pbcore', branch: 'fake_out'
gem 'curb'
# gem 'sony_ci_api', '~> 0.2.1'
# gem 'hyrax-iiif_av', '>= 0.2.0'
# gem 'hyrax-iiif_av', github: 'samvera-labs/hyrax-iiif_av', branch: 'hyrax_master'
gem 'webpacker'
gem 'react-rails'
gem 'database_cleaner'
gem 'redlock', '~> 1.0'
gem 'httparty', '~> 0.21'
# The maintainers yanked 0.3.2 version (see https://github.com/dryruby/json-canonicalization/issues/2)
gem 'json-canonicalization', "0.3.3"

# Sentry-ruby for error handling
gem "sentry-ruby"
# gem "sentry-rails"
# gem "sentry-sidekiq"

# Adding pry to all environments, because it's very useful for debugging
# production environments on demo instances.
gem 'pry-byebug', platforms: [:mri, :mingw, :x64_mingw]
gem 'activerecord-nulldb-adapter'
Plugin.send(:load_plugin, 'bootboot') if Plugin.installed?('bootboot')

if ENV['DEPENDENCIES_NEXT']
  enable_dual_booting if Plugin.installed?('bootboot')

  # Add any gem you want here, they will be loaded only when running
  # bundler command prefixed with `DEPENDENCIES_NEXT=1`.
end
