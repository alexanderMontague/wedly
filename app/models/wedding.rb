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
        location: config[:location],
        settings: {
          rsvp_deadline: config[:rsvp_deadline],
          meal_options: config[:meal_options] || []
        }
      )
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

    {
      total: total,
      accepted: accepted,
      declined: declined,
      pending: pending
    }
  end

  private

  def set_defaults
    self.settings ||= {}
  end
end
