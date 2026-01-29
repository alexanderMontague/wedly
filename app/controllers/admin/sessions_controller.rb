module Admin
  class SessionsController < ApplicationController
    layout "admin_auth"
    skip_before_action :require_admin, if: :admin_logged_in?, raise: false

    def new
      redirect_to admin_root_path if admin_logged_in?
    end

    def create
      admin = AdminUser.find_by(email: params[:email])

      if admin&.authenticate(params[:password])
        session[:admin_id] = admin.id
        redirect_to admin_root_path, notice: "Logged in successfully"
      else
        flash.now[:alert] = "Invalid email or password"
        render :new, status: :unprocessable_content
      end
    end

    def destroy
      session[:admin_id] = nil
      redirect_to admin_login_path, notice: "Logged out successfully"
    end

    private

    def admin_logged_in?
      session[:admin_id].present?
    end
  end
end
