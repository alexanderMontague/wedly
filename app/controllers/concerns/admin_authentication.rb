module AdminAuthentication
  extend ActiveSupport::Concern

  included do
    before_action :require_admin
  end

  private

  def require_admin
    return if current_admin

    redirect_to admin_login_path, alert: "Please log in to continue"
  end

  def current_admin
    @current_admin ||= AdminUser.find_by(id: session[:admin_id]) if session[:admin_id]
  end

  def admin_logged_in?
    current_admin.present?
  end

  helper_method :current_admin, :admin_logged_in?
end
