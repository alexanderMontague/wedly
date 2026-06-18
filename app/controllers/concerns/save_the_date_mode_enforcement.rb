module SaveTheDateModeEnforcement
  extend ActiveSupport::Concern

  included do
    before_action :redirect_to_save_the_date_unless_allowed!
  end

  private

  def redirect_to_save_the_date_unless_allowed!
    return unless current_wedding.save_the_date_mode?
    return if save_the_date_mode_allowed?

    redirect_to public_save_the_date_path
  end

  def save_the_date_mode_allowed?
    false
  end
end
