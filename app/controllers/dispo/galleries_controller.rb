module Dispo
  class GalleriesController < BaseController
    MAX_PHOTOS = 300

    def index
      @photos = DisposablePhoto.where(wedding_id: current_wedding.id).recent_first.limit(MAX_PHOTOS)
    end
  end
end
