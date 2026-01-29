class Invitation < ApplicationRecord
  belongs_to :guest

  STATUSES = %w[pending sent opened bounced].freeze

  validates :status, inclusion: { in: STATUSES }
  validates :guest, presence: true

  scope :sent, -> { where.not(sent_at: nil) }
  scope :pending, -> { where(sent_at: nil) }
  scope :opened, -> { where.not(opened_at: nil) }

  def mark_sent!
    update!(sent_at: Time.current, status: 'sent')
  end

  def mark_opened!
    update!(opened_at: Time.current, status: 'opened')
  end
end
