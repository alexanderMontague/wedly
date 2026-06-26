class RSVPConfirmationJob < ApplicationJob
  queue_as :default

  def perform(household_id)
    household = Household.find(household_id)
    guests = household.guests.includes(:rsvp).to_a

    return if guests.none? { |guest| guest.email.present? }

    RSVPConfirmationMailer.confirmation(
      guests:,
      wedding: Wedding.find(household.wedding_id)
    ).deliver_now
  end
end
