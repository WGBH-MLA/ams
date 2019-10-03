require 'json'
require 'aws-sdk-codedeploy'
require 'active_support/core_ext/numeric/time'

class DeploymentInfoPageGenerator < Rails::Generators::Base

  class_option :region, type: :string, default: 'us-east-1'
  class_option :deployment_id, type: :string

  def create_deployment_info_page
    create_file 'public/deployment.html', deployment_info_html, force: true
  end

  private

    # Accessors for command line options
    def region; options['region']; end
    def deployment_id; options['deployment_id']; end

    def client
      @client ||= Aws::CodeDeploy::Client.new(region: region)
    end

    def deployment_info
      @deployment_info ||= client.get_deployment(deployment_id: deployment_id).deployment_info
    end

    def git_commit
      @git_commit ||= deployment_info.revision.git_hub_location.commit_id
    end

    def github_repo
      @gitub_repo ||= deployment_info.revision.git_hub_location.repository
    end

    def github_commit_url
      "https://github.com/#{github_repo}/commit/#{git_commit}"
    end

    def formatted_date_time
      deployment_info.create_time.in_time_zone('Eastern Time (US & Canada)').strftime("%D %H:%M:%S %Z")
    end

    def deployment_info_html
      ERB.new(template).result(binding)
    rescue => e
      STDERR.puts "#{e.class}: #{e.message}"
      STDERR.puts "\n\t#{e.backtrace.join("\n\t")}"
      "An error occurred when attempting to generate this page: #{e.class}\n" \
      "See /opt/codedeploy-agent/deployment-root/deployment-logs/codedeploy-agent-deployments.log " \
      "on deployment destination host for full backtrace."
    end

    def template; File.read(template_path); end
    def template_path; File.expand_path('../../../app/views/public/deployment.html.erb', __FILE__); end
end
