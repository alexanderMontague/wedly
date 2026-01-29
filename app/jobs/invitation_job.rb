class InvitationJob < ApplicationJob
  queue_as :default

  def perform(guest_id)
    guest = Guest.find(guest_id)
    
    return unless guest.email.present?

    invitation = guest.invitations.create!(status: 'pending')
    
    InvitationMailer.invite(guest).deliver_now
    
    invitation.mark_sent!
  rescue StandardError => e
    Rails.logger.error("Failed to send invitation to guest #{guest_id}: #{e.message}")
    raise
  end
end
