class RSVPService
  def self.submit!(household:, rsvp_params:)
    ActiveRecord::Base.transaction do
      rsvp_params.each do |guest_id, attributes|
        guest = household.guests.find(guest_id)
        rsvp = guest.rsvp || guest.build_rsvp
        
        meal_options = attributes[:meal_choice].presence if attributes[:status] == 'accepted'
        
        rsvp.update!(
          status: attributes[:status],
          meal_choice: attributes[:status] == 'accepted' ? attributes[:meal_choice] : nil,
          dietary_restrictions: attributes[:dietary_restrictions],
          notes: attributes[:notes]
        )
      end

      { success: true }
    end
  rescue ActiveRecord::RecordInvalid => e
    { success: false, error: e.message }
  rescue StandardError => e
    { success: false, error: "An error occurred while saving your RSVP. Please try again." }
  end
end
