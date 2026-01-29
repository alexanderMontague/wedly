class Event < ApplicationRecord
  belongs_to :wedding

  validates :name, presence: true

  scope :ordered, -> { order(:datetime) }
  scope :upcoming, -> { where("datetime > ?", Time.current).ordered }
  scope :past, -> { where(datetime: ..Time.current).order(datetime: :desc) }
end
