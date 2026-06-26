# Preview at http://localhost:3003/rails/mailers/wedding_reminder_mailer/reminder
class WeddingReminderMailerPreview < ActionMailer::Preview
  def reminder
    WeddingReminderMailer.reminder(
      guest: EmailSampleData.accepted_guest,
      wedding: Wedding.current,
      subject: "Your wedding RSVP: one week to go"
    )
  end
end
