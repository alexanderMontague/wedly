module ApplicationHelper
  def page_title(title = nil)
    base_title = "Wedly"
    title.present? ? "#{title} | #{base_title}" : base_title
  end

  def format_date(date)
    date&.strftime("%B %d, %Y")
  end

  def format_date_elegant(date)
    return nil unless date

    day_words = {
      1 => "First", 2 => "Second", 3 => "Third", 4 => "Fourth", 5 => "Fifth",
      6 => "Sixth", 7 => "Seventh", 8 => "Eighth", 9 => "Ninth", 10 => "Tenth",
      11 => "Eleventh", 12 => "Twelfth", 13 => "Thirteenth", 14 => "Fourteenth", 15 => "Fifteenth",
      16 => "Sixteenth", 17 => "Seventeenth", 18 => "Eighteenth", 19 => "Nineteenth", 20 => "Twentieth",
      21 => "Twenty-First", 22 => "Twenty-Second", 23 => "Twenty-Third", 24 => "Twenty-Fourth", 25 => "Twenty-Fifth",
      26 => "Twenty-Sixth", 27 => "Twenty-Seventh", 28 => "Twenty-Eighth", 29 => "Twenty-Ninth", 30 => "Thirtieth",
      31 => "Thirty-First"
    }

    year_words = {
      2024 => "Two Thousand Twenty-Four",
      2025 => "Two Thousand Twenty-Five",
      2026 => "Two Thousand Twenty-Six",
      2027 => "Two Thousand Twenty-Seven",
      2028 => "Two Thousand Twenty-Eight",
      2029 => "Two Thousand Twenty-Nine",
      2030 => "Two Thousand Thirty"
    }

    month = date.strftime("%B")
    day = day_words[date.day] || date.day.to_s
    year = year_words[date.year] || date.year.to_s

    "#{month} #{day}, #{year}"
  end

  def couple_initials(title)
    names = title.to_s.split(/\s*[&+]\s*/)
    if names.length >= 2
      "#{names[0][0]} & #{names[1].split.first[0]}"
    else
      title.to_s[0..2]
    end
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
