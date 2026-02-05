class Wedding < FrozenRecord::Base
  self.base_path = "db/"

  class << self
    def current
      @current ||= first_or_error!
    end

    def reset_current!
      @current = nil
    end

    private

    def first_or_error!
      first || raise("No wedding found")
    end
  end

  def guests
    Guest.where(wedding_id: id)
  end

  def households
    Household.where(wedding_id: id)
  end

  def events
    Event.where(wedding_id: id)
  end

  def metadata
    WeddingMetadata.where(wedding_id: id)
  end

  def date
    Date.parse(super)
  end

  def rsvp_stats
    total = guests.count
    accepted = guests.joins(:rsvp).where(rsvps: { status: "accepted" }).count
    declined = guests.joins(:rsvp).where(rsvps: { status: "declined" }).count
    pending = total - accepted - declined

    { total:, accepted:, declined:, pending: }
  end
end
