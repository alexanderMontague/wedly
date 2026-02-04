class Wedding < ApplicationRecord
  has_many :events, dependent: :destroy
  has_many :households, dependent: :destroy
  has_many :guests, dependent: :destroy

  store_accessor :settings, :rsvp_deadline, :meal_options

  validates :title, presence: true

  after_initialize :set_defaults, if: :new_record?

  class << self
    def current
      @current ||= first_or_create_from_config!
    end

    def config
      @config ||= Rails.application.config_for(:wedding).deep_symbolize_keys
    end

    def reset_current!
      @current = nil
    end

    private

    def first_or_create_from_config!
      wedding = first
      return wedding if wedding

      create!(
        title: config[:title],
        date: config[:date],
        location: format_location,
        settings: {
          rsvp_deadline: config[:rsvp_deadline],
          meal_options: config[:meal_options] || []
        }
      )
    end

    def format_location
      venue = config[:venue] || {}
      [venue[:name], venue[:city], venue[:region]].compact.join(", ")
    end
  end

  def meal_options
    super || []
  end

  def meal_options_text
    meal_options.join("\n")
  end

  def meal_options_text=(value)
    self.meal_options = value.to_s.split("\n").map(&:strip).reject(&:blank?)
  end

  def rsvp_stats
    total = guests.count
    accepted = guests.joins(:rsvp).where(rsvps: { status: "accepted" }).count
    declined = guests.joins(:rsvp).where(rsvps: { status: "declined" }).count
    pending = total - accepted - declined

    { total:, accepted:, declined:, pending: }
  end

  def couple
    self.class.config[:couple] || {}
  end

  def initials
    couple[:initials] || title.to_s[0..2]
  end

  def partner1
    couple[:partner1]
  end

  def partner2
    couple[:partner2]
  end

  def venue
    self.class.config[:venue] || {}
  end

  def venue_name
    venue[:name]
  end

  def venue_city
    venue[:city]
  end

  def venue_region
    venue[:region]
  end

  def venue_full
    [venue_name, venue_city, venue_region].compact.join(", ")
  end

  def ceremony_time
    self.class.config[:ceremony_time]
  end

  def hero
    self.class.config[:hero] || {}
  end

  def story
    self.class.config[:story] || {}
  end

  def gallery
    self.class.config[:gallery] || {}
  end

  def rsvp_content
    self.class.config[:rsvp] || {}
  end

  def date_elegant
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

  def date_short
    date&.strftime("%m.%d.%Y")
  end

  def date_formatted
    date&.strftime("%B %e, %Y")&.gsub(/\s+/, " ")
  end

  def rsvp_deadline_formatted
    return nil unless rsvp_deadline

    Date.parse(rsvp_deadline).strftime("%B %e, %Y").gsub(/\s+/, " ")
  end

  private

  def set_defaults
    self.settings ||= {}
  end
end
