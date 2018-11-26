class Ams2Mailer < ApplicationMailer

  def export_notification(user,export_url)
    @export_url = export_url
    mail(to: user.email, subject: 'AMS2 Download Export File')
  end
end
