module Admin
  class SettingsController < Admin::BaseController
    def show
      @flag_definitions = WeddingFeatureFlags.by_category
      @flag_overrides = current_wedding.metadata
                                       .where(key: WeddingFeatureFlags.keys)
                                       .index_by(&:key)
    end

    def update
      WeddingMetadata.transaction do
        flag_params.each do |key, value|
          next unless WeddingFeatureFlags.find(key)

          record = WeddingMetadata.find_or_initialize_by(
            wedding_id: current_wedding.id,
            key: key
          )

          if value.blank?
            record.destroy if record.persisted?
          else
            record.value = value
            record.save!
          end
        end
      end

      redirect_to admin_settings_path, notice: "Settings updated."
    rescue ActiveRecord::RecordInvalid => e
      flash[:alert] = e.message
      redirect_to admin_settings_path
    end

    private

    def flag_params
      params.require(:flags).permit(WeddingFeatureFlags.keys).to_h
    rescue ActionController::ParameterMissing
      {}
    end
  end
end
