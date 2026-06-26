# Preview at http://localhost:3003/rails/mailers/invitation_mailer/invite
class InvitationMailerPreview < ActionMailer::Preview
  def invite
    InvitationMailer.invite(EmailSampleData.accepted_guest)
  end
end
