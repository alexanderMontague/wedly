class Wedding < ApplicationRecord
  has_many :events, dependent: :destroy
  has_many :households, dependent: :destroy
  has_many :guests, dependent: :destroy

  store_accessor :settings, :rsvp_deadline, :meal_options
  store_accessor :theme_config, :font, :layout

  validates :slug, presence: true, uniqueness: true, format: { with: /\A[a-z0-9-]+\z/ }
  validates :title, presence: true

  after_initialize :set_defaults, if: :new_record?
  before_validation :generate_slug, on: :create

  def meal_options
    super || []
  end

  def meal_options_text
    meal_options.join("\n")
  end

  def meal_options_text=(value)
    self.meal_options = value.to_s.split("\n").map(&:strip).reject(&:blank?)
  end

  def primary_color
    theme_config.dig("colors", "primary") || "#C89B7B"
  end

  def primary_color=(value)
    self.theme_config ||= {}
    self.theme_config["colors"] ||= {}
    self.theme_config["colors"]["primary"] = value
  end

  def secondary_color
    theme_config.dig("colors", "secondary") || "#8B7355"
  end

  def secondary_color=(value)
    self.theme_config ||= {}
    self.theme_config["colors"] ||= {}
    self.theme_config["colors"]["secondary"] = value
  end

  def rsvp_stats
    total = guests.count
    accepted = guests.joins(:rsvp).where(rsvps: { status: "accepted" }).count
    declined = guests.joins(:rsvp).where(rsvps: { status: "declined" }).count
    pending = total - accepted - declined

    {
      total: total,
      accepted: accepted,
      declined: declined,
      pending: pending
    }
  end

  private

  def set_defaults
    self.theme_config ||= {}
    self.settings ||= {}
  end

  def generate_slug
    return if slug.present?

    self.slug = title.parameterize if title.present?
  end
end
