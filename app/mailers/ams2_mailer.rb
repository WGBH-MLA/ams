class Ams2Mailer < ApplicationMailer

  def export_notification(user, export_url)
    @export_url = export_url
    mail(to: user.email, subject: "AMS2 Download Export File")
  end

  def scp_to_aapb_notification(user, output, env_name)
    mail(to: user.email, subject: "(#{env_name}) AMS2 to AAPB Copy Output", body: output)
  end

  def export_job_failure(user, env_name)
    mail(to: user, subject: "(#{env_name}) AMS2 to AAPB Failed")
  end
end
