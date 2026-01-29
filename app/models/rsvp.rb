class RSVP < ApplicationRecord
  belongs_to :guest

  STATUSES = %w[pending accepted declined].freeze

  validates :status, presence: true, inclusion: { in: STATUSES }

  scope :accepted, -> { where(status: "accepted") }
  scope :declined, -> { where(status: "declined") }
  scope :pending, -> { where(status: "pending") }

  def accepted?
    status == "accepted"
  end

  def declined?
    status == "declined"
  end

  def pending?
    status == "pending"
  end
end
