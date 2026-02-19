module Admin
  class DisposablePhotosController < Admin::BaseController
    def index
      @photos = scoped_photos.includes(:guest).recent_first
    end

    def destroy_selected
      photo_ids = Array(params[:photo_ids]).map(&:to_s).uniq

      if photo_ids.empty?
        redirect_to admin_disposable_photos_path, alert: "Select at least one photo to delete"
        return
      end

      deleted_count = scoped_photos.where(id: photo_ids).destroy_all.size

      redirect_to(
        admin_disposable_photos_path,
        notice: "#{deleted_count} #{'photo'.pluralize(deleted_count)} deleted"
      )
    end

    def destroy_all
      deleted_count = scoped_photos.destroy_all.size

      redirect_to(
        admin_disposable_photos_path,
        notice: "#{deleted_count} #{'photo'.pluralize(deleted_count)} deleted"
      )
    end

    private

    def scoped_photos
      DisposablePhoto.where(wedding_id: current_wedding.id)
    end
  end
end
