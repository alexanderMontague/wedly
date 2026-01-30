module Public
  class WeddingsController < ApplicationController
    layout "public"

    def show
      @wedding = Wedding.current
      @events = @wedding.events.upcoming.ordered
    end
  end
end
