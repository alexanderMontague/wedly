class InvitationMailer < ApplicationMailer
  def invite(guest)
    @guest = guest
    @wedding = Wedding.find(guest.wedding_id)
    @rsvp_url = public_rsvp_url(@guest.invite_code)

    mail(
      to: @guest.email,
      subject: "You're Invited to #{@wedding.title}!"
    )
  end
end
