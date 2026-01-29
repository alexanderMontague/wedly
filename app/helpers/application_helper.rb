module ApplicationHelper
  def page_title(title = nil)
    base_title = "Wedly"
    title.present? ? "#{title} | #{base_title}" : base_title
  end

  def format_date(date)
    date&.strftime("%B %d, %Y")
  end

  def format_datetime(datetime)
    datetime&.strftime("%B %d, %Y at %I:%M %p")
  end

  def rsvp_status_badge(status)
    color = case status
            when "accepted" then "green"
            when "declined" then "red"
            else "orange"
            end

    content_tag(:span, status.capitalize, style: "color: #{color}; font-weight: bold;")
  end
end
