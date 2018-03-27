#!/usr/bin/env ruby
require 'json'
require 'aws-sdk-codedeploy'
require 'pry-byebug'
require 'active_support/core_ext/numeric/time'

class DeploymentDetails
  attr_reader :deployment_id, :region

  def initialize(deployment_id:, region: 'us-east-1')
    @deployment_id = deployment_id
    @region = region
  end

  def create_page(filename)
    File.write(filename, deployment_details_html)
  end

  private

    def client
      @client ||= Aws::CodeDeploy::Client.new(region: region)
    end

    def response
      @response ||= client.get_deployment deployment_id: deployment_id
    end

    def git_commit
      @git_commit ||= response.deployment_info.revision.git_hub_location.commit_id
    end

    def github_repo
      @gitub_repo ||= response.deployment_info.revision.git_hub_location.repository
    end

    def github_commit_url
      "https://github.com/#{github_repo}/commit/#{git_commit}"
    end

    def deployment_details_html
      # TODO: use ERB if the HTML gets more complex.
      html = "<strong>Current revision:</strong> <a href=\"#{github_commit_url}\" title=\"Current revision: #{git_commit}\">#{git_commit}</a>"
      html += "<br /><strong>Deployed:</strong> " + (response.deployment_info.create_time - 6.hours).strftime("%D %H:%M:%S") + " Eastern Time"
    end
end


# Create the page. Catch any errors, print them, and continue.
begin
  DeploymentDetails.new(deployment_id: ENV['DEPLOYMENT_ID'].to_str).create_page File.expand_path('../../../public/deployment_details.html', __FILE__)
rescue => e
  backtrace = e.backtrace.reverse.join("\n")
  puts "\n\nError creating deployment information page. #{e.message}\n\n#{backtrace}\n\n"
end
