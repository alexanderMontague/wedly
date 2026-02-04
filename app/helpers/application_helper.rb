module ApplicationHelper
  def page_title(title = nil)
    base_title = @wedding&.title || "Wedding"
    title.present? ? "#{title} | #{base_title}" : base_title
  end

  def format_date(date)
    date&.strftime("%B %d, %Y")
  end

  def format_datetime(datetime)
    datetime&.strftime("%B %d, %Y at %I:%M %p")
  end

  def rsvp_status_badge(status)
    css_class = case status
                when "accepted" then "badge-success"
                when "declined" then "badge-danger"
                else "badge-warning"
                end

    content_tag(:span, status.capitalize, class: "badge #{css_class}")
  end
end
