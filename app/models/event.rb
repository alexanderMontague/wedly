class Event < ApplicationRecord
  validates :name, presence: true

  scope :ordered, -> { order(:datetime) }
  scope :upcoming, -> { where("datetime > ?", Time.current).ordered }
  scope :past, -> { where(datetime: ..Time.current).order(datetime: :desc) }

  def wedding
    Wedding.find(wedding_id)
  end
end
