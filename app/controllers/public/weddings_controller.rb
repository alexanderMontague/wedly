module Public
  class WeddingsController < Public::BaseController
    DISPO_GALLERY_PREVIEW_COUNT = 4

    def show
      @events = current_wedding.events.upcoming.ordered

      if current_wedding.dispo_gallery_on_main_page?
        @dispo_photos = DisposablePhoto.where(wedding_id: current_wedding.id)
                                       .recent_first
                                       .limit(DISPO_GALLERY_PREVIEW_COUNT)
      end
    end
  end
end
