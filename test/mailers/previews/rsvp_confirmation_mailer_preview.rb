# Preview at http://localhost:3003/rails/mailers/rsvp_confirmation_mailer/confirmation
class RSVPConfirmationMailerPreview < ActionMailer::Preview
  def confirmation
    RSVPConfirmationMailer.confirmation(
      guests: [EmailSampleData.accepted_guest, EmailSampleData.declined_guest],
      wedding: Wedding.current
    )
  end
end
