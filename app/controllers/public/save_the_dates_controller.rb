module Public
  class SaveTheDatesController < Public::BaseController
    include WeddingHelper

    def show
    end

    def calendar
      return head :not_found unless current_wedding&.date

      wedding_date = current_wedding.date
      start_time = wedding_date.beginning_of_day
      end_time = wedding_date.end_of_day
      title = current_wedding.title
      description = "Join us for our wedding celebration!"
      location = current_wedding.venue ? full_venue_name(current_wedding.venue) : ""

      ics_content = generate_ics(
        title: title,
        description: description,
        location: location,
        start_time: start_time,
        end_time: end_time
      )

      respond_to do |format|
        format.ics do
          send_data ics_content,
                    filename: "wedding-invitation.ics",
                    type: "text/calendar",
                    disposition: "attachment"
        end
      end
    end

    private

    def generate_ics(title:, description:, location:, start_time:, end_time:)
      <<~ICS
        BEGIN:VCALENDAR
        VERSION:2.0
        PRODID:-//Wedly//Wedding Invitation//EN
        CALSCALE:GREGORIAN
        METHOD:PUBLISH
        BEGIN:VEVENT
        UID:#{SecureRandom.uuid}@wedly.com
        DTSTAMP:#{Time.current.utc.strftime('%Y%m%dT%H%M%SZ')}
        DTSTART:#{start_time.utc.strftime('%Y%m%dT%H%M%SZ')}
        DTEND:#{end_time.utc.strftime('%Y%m%dT%H%M%SZ')}
        SUMMARY:#{escape_ics_text(title)}
        DESCRIPTION:#{escape_ics_text(description)}
        LOCATION:#{escape_ics_text(location)}
        STATUS:CONFIRMED
        SEQUENCE:0
        BEGIN:VALARM
        TRIGGER:-P1D
        ACTION:DISPLAY
        DESCRIPTION:Reminder: #{escape_ics_text(title)} tomorrow
        END:VALARM
        END:VEVENT
        END:VCALENDAR
      ICS
    end

    def escape_ics_text(text)
      return "" if text.blank?

      text.to_s
          .gsub("\\", "\\\\")
          .gsub(",", "\\,")
          .gsub(";", "\\;")
          .gsub("\n", "\\n")
          .strip
    end
  end
end
