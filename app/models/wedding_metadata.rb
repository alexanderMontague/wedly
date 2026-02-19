class WeddingMetadata < ApplicationRecord
  include UuidPrimaryKey

  validates :key, presence: true, uniqueness: { scope: :wedding_id }
  validates :value, presence: true

  def wedding
    Wedding.find(wedding_id)
  end
end
