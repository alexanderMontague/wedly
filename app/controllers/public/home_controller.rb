module Public
  class HomeController < ApplicationController
    layout "public"

    def index
      @wedding = Wedding.first
      redirect_to public_wedding_path(@wedding.slug) if @wedding
    end
  end
end
