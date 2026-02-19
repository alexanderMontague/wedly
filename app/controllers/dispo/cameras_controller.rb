module Dispo
  class CamerasController < BaseController
    MAX_UPLOAD_BYTES = 15.megabytes

    def show
      @total_photos = DisposablePhoto.where(wedding_id: current_wedding.id).count
    end

    def create
      uploaded_file = upload_params.fetch(:photo)
      content_type = uploaded_file.content_type
      ensure_supported_upload!(uploaded_file:, content_type:)
      object_key = DisposableCamera::ObjectKeyBuilder.build(wedding_code: current_wedding.id,
                                                            content_type: content_type)

      DisposableCamera::StorageClient.upload!(io: uploaded_file.tempfile, object_key:, content_type:)

      photo = DisposablePhoto.create!(
        wedding_id: current_wedding.id,
        object_key: object_key,
        content_type: content_type,
        byte_size: uploaded_file.size,
        flash_enabled: flash_enabled?,
        captured_at: captured_at,
        source_ip: request.remote_ip
      )

      @total_photos = DisposablePhoto.where(wedding_id: current_wedding.id).count

      respond_to do |format|
        format.json do
          render json: {
            id: photo.id,
            image_url: DisposableCamera::StorageClient.public_url_for(photo.object_key),
            captured_at: photo.captured_at.iso8601
          }, status: :created
        end

        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            "dispo-total-photos",
            partial: "dispo/cameras/total_photos",
            locals: { total_photos: @total_photos }
          ), status: :created
        end
      end
    rescue KeyError, ArgumentError => e
      render json: { error: e.message }, status: :unprocessable_content
    rescue Aws::S3::Errors::ServiceError, Seahorse::Client::NetworkingError
      render json: { error: "Upload service is temporarily unavailable. Please try again." },
             status: :service_unavailable
    end

    private

    def upload_params
      params.permit(:photo, :flash_enabled, :captured_at)
    end

    def flash_enabled?
      ActiveModel::Type::Boolean.new.cast(upload_params[:flash_enabled])
    end

    def captured_at
      value = upload_params[:captured_at]
      return Time.current if value.blank?

      Time.iso8601(value)
    rescue ArgumentError
      Time.current
    end

    def ensure_supported_upload!(uploaded_file:, content_type:)
      raise ArgumentError, "Image is too large." if uploaded_file.size > MAX_UPLOAD_BYTES
      raise ArgumentError, "Unsupported image type." unless DisposablePhoto::CONTENT_TYPES.include?(content_type)
    end
  end
end
