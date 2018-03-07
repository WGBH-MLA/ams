unless Rails.env.production?
  APP_ROOT = File.dirname(__FILE__)
  require "solr_wrapper"
  require "fcrepo_wrapper"
  require 'solr_wrapper/rake_task'

  desc "Run Continuous Integration"
  task :ci do
    ENV["environment"] = "test"
    solr_params = {
      config: 'config/solr_wrapper_test.yml'
    }
    fcrepo_params = {
      config: 'config/fcrepo_wrapper_test.yml'
    }

    SolrWrapper.wrap(solr_params) do |solr|
      solr.with_collection(
        name: "hydra-test",
        persist: false,
        dir: Rails.root.join("solr", "config")
      ) do
        FcrepoWrapper.wrap(fcrepo_params) do
          Rake::Task["spec"].invoke
        end
      end
    end
  end
end
