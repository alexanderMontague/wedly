module WeddingHelper
  def full_venue_name(venue_hash)
    [venue_hash["name"], venue_hash["city"], venue_hash["region"]].compact.join(", ")
  end

  def wedding_datetime_iso(wedding)
    return unless wedding&.date

    tz = ActiveSupport::TimeZone[wedding.timezone] || Time.zone
    time_str = wedding.ceremony_time.presence || "12:00 PM"
    tz.parse("#{wedding.date} #{time_str}").iso8601
  rescue ArgumentError, TypeError
    wedding.date.beginning_of_day.in_time_zone(tz).iso8601
  end
end
