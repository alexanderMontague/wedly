class InvitationMailer < ApplicationMailer
  def invite(guest)
    @guest = guest
    @wedding = guest.wedding
    @rsvp_url = public_rsvp_url(@guest.invite_code)

    mail(
      to: @guest.email,
      subject: "You're Invited to #{@wedding.title}!"
    )
  end
end
