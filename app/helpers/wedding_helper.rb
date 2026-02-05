module WeddingHelper
  def full_venue_name(venue_hash)
    [venue_hash["name"], venue_hash["city"], venue_hash["region"]].compact.join(", ")
  end
end
