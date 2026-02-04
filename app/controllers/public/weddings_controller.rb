module Public
  class WeddingsController < Public::BaseController
    def show
      @events = current_wedding.events.upcoming.ordered
    end
  end
end
