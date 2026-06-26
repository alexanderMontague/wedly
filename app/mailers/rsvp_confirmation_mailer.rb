class RSVPConfirmationMailer < ApplicationMailer
  def confirmation(guests:, wedding:)
    @guests = guests
    @wedding = wedding
    @rsvp_url = public_rsvp_url(@guests.first.invite_code)

    recipients = @guests.map(&:email).compact_blank.uniq
    return if recipients.empty?

    mail(
      to: recipients,
      subject: "We've received your RSVP for #{@wedding.title}"
    )
  end
end
