module ApplicationHelper
  def page_title(title = nil)
    base_title = current_wedding&.title || "Wedding"
    title.present? ? "#{title} | #{base_title}" : base_title
  end

  def format_date(date)
    return nil unless date.present? && date.is_a?(String)

    date = Date.parse(date)

    date.strftime("%B %d, %Y")
  end

  def format_datetime(datetime)
    return nil unless datetime.present? && datetime.is_a?(String)

    datetime = DateTime.parse(datetime)

    datetime.strftime("%B %d, %Y at %I:%M %p")
  end

  def format_date_short(date)
    return nil unless date.present? && date.is_a?(String)

    date = Date.parse(date)

    date.strftime("%m.%d.%Y")
  end

  def format_date_elegant(date)
    return nil unless date.present? && date.is_a?(String)

    date = Date.parse(date)

    day_words = {
      1 => "First", 2 => "Second", 3 => "Third", 4 => "Fourth", 5 => "Fifth",
      6 => "Sixth", 7 => "Seventh", 8 => "Eighth", 9 => "Ninth", 10 => "Tenth",
      11 => "Eleventh", 12 => "Twelfth", 13 => "Thirteenth", 14 => "Fourteenth", 15 => "Fifteenth",
      16 => "Sixteenth", 17 => "Seventeenth", 18 => "Eighteenth", 19 => "Nineteenth", 20 => "Twentieth",
      21 => "Twenty-First", 22 => "Twenty-Second", 23 => "Twenty-Third", 24 => "Twenty-Fourth", 25 => "Twenty-Fifth",
      26 => "Twenty-Sixth", 27 => "Twenty-Seventh", 28 => "Twenty-Eighth", 29 => "Twenty-Ninth", 30 => "Thirtieth",
      31 => "Thirty-First"
    }

    year_words = (2024..2035).to_h do |y|
      ones = %w[Twenty Twenty-One Twenty-Two Twenty-Three Twenty-Four Twenty-Five Twenty-Six Twenty-Seven Twenty-Eight
                Twenty-Nine Thirty Thirty-One Thirty-Two Thirty-Three Thirty-Four Thirty-Five]
      [y, "Two Thousand #{ones[y - 2020]}"]
    end

    month = date.strftime("%B")
    day = day_words[date.day] || date.day.to_s
    year = year_words[date.year] || date.year.to_s

    "#{month} #{day}, #{year}"
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
