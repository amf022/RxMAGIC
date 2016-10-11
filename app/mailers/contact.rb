class Contact < ApplicationMailer

  default from: "#{ENV['gmail_username'].strip}@gmail.com"

  def report_contact(from,email,message)
    @from = from
    @contact_email = email
    @body = message
    mail(to: ENV['rxmagic_contact'], subject: "Test")
  end
end
