class Wedding < ApplicationRecord
  has_many :events, dependent: :destroy
  has_many :households, dependent: :destroy
  has_many :guests, dependent: :destroy

  validates :slug, presence: true, uniqueness: true, format: { with: /\A[a-z0-9-]+\z/ }
  validates :title, presence: true

  after_initialize :set_defaults, if: :new_record?
  before_validation :generate_slug, on: :create

  def rsvp_deadline
    settings["rsvp_deadline"]
  end

  def meal_options
    settings["meal_options"] || []
  end

  def primary_color
    theme_config.dig("colors", "primary") || "#C89B7B"
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
