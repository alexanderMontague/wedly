module WeddingConcern
  extend ActiveSupport::Concern

  included do
    helper_method :current_wedding
  end

  private

  def current_wedding
    @current_wedding ||= Wedding.current
  end
end
