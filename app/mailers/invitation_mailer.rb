class InvitationMailer < ApplicationMailer
  def invite(guest)
    @guest = guest
    @rsvp_url = public_rsvp_url(@guest.invite_code)

    mail(
      to: @guest.email,
      subject: "You're Invited to #{current_wedding.title}!"
    )
  end
end
