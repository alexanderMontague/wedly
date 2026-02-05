module Admin
  class SettingsController < Admin::BaseController
    def create
      if WeddingMetadata.create(params.permit(:key, :value))
        redirect_to admin_settings_path, notice: "Settings updated successfully"
      else
        render :show, status: :unprocessable_content
      end
    end
  end
end
