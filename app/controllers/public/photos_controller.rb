module Public
  class PhotosController < Public::BaseController
    DISPO_PER_PAGE = 24
    DISPO_MAX_PER_PAGE = 96

    def show
      load_dispo_photos if current_wedding.dispo_gallery_visible?
    end

    private

    def load_dispo_photos
      scope = DisposablePhoto.where(wedding_id: current_wedding.id).recent_first

      @dispo_per_page = [normalized_dispo_per_page, DISPO_MAX_PER_PAGE].min
      @dispo_total    = scope.count
      @dispo_total_pages = (@dispo_total.to_f / @dispo_per_page).ceil

      @dispo_page = begin
        page = params[:page].to_i.positive? ? params[:page].to_i : 1
        @dispo_total_pages.positive? ? [page, @dispo_total_pages].min : page
      end

      @dispo_photos          = scope.offset((@dispo_page - 1) * @dispo_per_page).limit(@dispo_per_page)
      @dispo_has_prev_page   = @dispo_page > 1
      @dispo_has_next_page   = @dispo_page < @dispo_total_pages
    end

    def normalized_dispo_per_page
      requested = params[:per_page].to_i
      requested.positive? ? requested : DISPO_PER_PAGE
    end
  end
end
