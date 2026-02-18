class DisposablePhoto < ApplicationRecord
  CONTENT_TYPES = %w[image/jpeg image/png image/webp].freeze

  belongs_to :guest, optional: true

  validates :wedding_id, presence: true
  validates :object_key, presence: true, uniqueness: true
  validates :content_type, inclusion: { in: CONTENT_TYPES }
  validates :byte_size, numericality: { greater_than: 0 }

  scope :recent_first, -> { order(created_at: :desc) }
end
