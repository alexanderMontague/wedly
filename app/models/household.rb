class Household < ApplicationRecord
  belongs_to :wedding
  has_many :guests, dependent: :destroy

  validates :name, presence: true

  def primary_guest
    guests.order(:created_at).first
  end

  def guest_names
    guests.map(&:full_name).join(", ")
  end
end
