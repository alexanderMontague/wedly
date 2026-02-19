module UuidPrimaryKey
  extend ActiveSupport::Concern

  included do
    before_validation :assign_uuid_primary_key, on: :create
  end

  private

  def assign_uuid_primary_key
    return unless has_attribute?(:id)
    return if self[:id].present?

    self[:id] = SecureRandom.uuid
  end
end
