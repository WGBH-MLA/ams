class Ams2Mailer < ApplicationMailer

  def export_notification(user, export_url)
    @export_url = export_url
    mail(to: user.email, subject: 'AMS2 Download Export File')
  end

  def scp_to_aapb_notification(user, output)
    mail(to: user.email, subject: 'AMS2 to AAPB Copy Output', body: output)
  end

  def export_job_failure(user, environment)
    mail(to: user, subject: "(#{environment}) AMS2 to AAPB Failed")
  end
end
