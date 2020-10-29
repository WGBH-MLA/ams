source 'https://rubygems.org'

ruby '2.5.3'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

gem 'dotenv-rails'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.1.5'
# Use Puma as the app server
gem 'puma', '~> 3.12'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
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
gem 'sidekiq'
gem 'hydra-role-management', '~> 1.0'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

group :production do
  gem 'mysql2', '~> 0.4.10'
end

group :development, :test do
  # Use sqlite3 as the database for Active Record
  gem 'sqlite3', '1.3.13'
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'
  gem 'pry-byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'pry-rails'
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
  gem 'faker'
  gem 'xray-rails'
end

gem 'hyrax', '2.5.1'
gem 'blacklight_advanced_search', '~> 6.4.0'
gem 'rsolr', '>= 1.0'
gem 'jquery-rails'
gem 'devise'
gem 'devise-guests', '~> 0.6'
gem 'simple_form', '3.5.0'
gem 'aws-sdk-s3'
gem 'aws-sdk-codedeploy'
gem 'carrierwave', '~> 1.0'
gem 'nokogiri'
gem 'bootstrap-multiselect-rails'
gem 'hyrax-batch_ingest', git: 'https://github.com/samvera-labs/hyrax-batch_ingest'
gem 'pbcore', '~> 0.3.0'
gem 'curb'
gem 'sony_ci_api', '~> 0.2.1'
# gem 'hyrax-iiif_av', '>= 0.2.0'
# gem 'hyrax-iiif_av', github: 'samvera-labs/hyrax-iiif_av', branch: 'hyrax_master'
gem 'webpacker'
gem 'react-rails'
gem 'faker'
gem 'database_cleaner'
gem 'redlock', '~> 1.0'
