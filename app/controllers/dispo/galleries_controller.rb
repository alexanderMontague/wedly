module Dispo
  class GalleriesController < BaseController
    DEFAULT_PER_PAGE = 48
    MAX_PER_PAGE = 96

    def index
      scope = DisposablePhoto.where(wedding_id: current_wedding.id).recent_first

      @per_page = normalized_per_page
      @total_photos = scope.count
      @total_pages = (@total_photos.to_f / @per_page).ceil
      @page = normalized_page(@total_pages)

      @photos = scope.offset((@page - 1) * @per_page).limit(@per_page)
      @has_previous_page = @page > 1
      @has_next_page = @page < @total_pages
    end

    private

    def normalized_page(total_pages)
      requested_page = params[:page].to_i
      page = requested_page.positive? ? requested_page : 1
      page = [page, total_pages].min if total_pages.positive?
      page
    end

    def normalized_per_page
      requested_per_page = params[:per_page].to_i
      per_page = requested_per_page.positive? ? requested_per_page : DEFAULT_PER_PAGE

      [per_page, MAX_PER_PAGE].min
    end
  end
end
