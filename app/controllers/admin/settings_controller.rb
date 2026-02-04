module Admin
  class SettingsController < Admin::BaseController
    def show
    end

    def update
      if current_wedding.update(wedding_params)
        redirect_to admin_settings_path, notice: "Settings updated successfully"
      else
        render :show, status: :unprocessable_content
      end
    end

    private

    def wedding_params
      params.require(:wedding).permit(
        :title, :date, :location,
        :rsvp_deadline, :meal_options_text
      )
    end
  end
end
