class ApplicationMailer < ActionMailer::Base
  default from: ENV.fetch("SMTP_USERNAME", "noreply@wedly.com")
  layout "mailer"
end
