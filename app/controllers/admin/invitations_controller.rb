module Admin
  class InvitationsController < Admin::BaseController
    def index
      @guests = current_wedding.guests.with_email.includes(:invitations, :household)
      @invitation_stats = calculate_invitation_stats
    end

    def create
      guest_ids = params[:guest_ids] || []

      if guest_ids.empty?
        redirect_to admin_invitations_path, alert: "Please select at least one guest"
        return
      end

      guests = current_wedding.guests.where(id: guest_ids).with_email

      guests.each do |guest|
        InvitationJob.perform_later(guest.id)
      end

      redirect_to admin_invitations_path,
                  notice: "#{guests.count} invitation(s) queued for sending"
    end

    private

    def calculate_invitation_stats
      guests = current_wedding.guests.with_email
      invitations = Invitation.where(guest_id: guests.pluck(:id))

      {
        total_guests: guests.count,
        sent: invitations.sent.count,
        pending: guests.count - invitations.sent.count,
        opened: invitations.opened.count
      }
    end
  end
end
