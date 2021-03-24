class ExportMailer < ApplicationMailer
  def push_to_aapb_failed
    @error_message = params[:error_message]
    mail(to: params[:user], subject: 'Export to AAPB Failed')
  end

  def push_to_aapb_succeeded
    @remote_ingest_output = params[:remote_ingest_output]
    mail(to: params[:user], subject: 'Export to AAPB Succeeded')
  end

  def export_to_s3_failed
    @error_message = params[:error_message]
    mail(to: params[:user], subject: 'Export to S3 Failed')
  end

  def export_to_s3_succeeded
    @download_url = params[:download_url]
    mail(to: params[:user], subject: 'AMS export to S3 is ready for download')
  end
end
