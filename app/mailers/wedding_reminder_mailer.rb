class WeddingReminderMailer < ApplicationMailer
  helper ApplicationHelper

  def reminder(guest:, wedding:, subject:)
    @guest = guest
    @wedding = wedding
    @rsvp_url = public_rsvp_url(@guest.invite_code)

    mail(to: @guest.email, subject: subject)
  end
end
