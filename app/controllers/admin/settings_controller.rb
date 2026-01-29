module Admin
  class SettingsController < Admin::BaseController
    def show
      @wedding = current_wedding
    end

    def update
      @wedding = current_wedding

      if @wedding.update(wedding_params)
        redirect_to admin_settings_path, notice: "Settings updated successfully"
      else
        render :show, status: :unprocessable_content
      end
    end

    private

    def wedding_params
      params.require(:wedding).permit(
        :title, :date, :location,
        :rsvp_deadline, :meal_options_text,
        :primary_color, :secondary_color, :font, :layout
      )
    end
  end
end
