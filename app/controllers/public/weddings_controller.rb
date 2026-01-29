class Public::WeddingsController < ApplicationController
  layout 'public'

  def show
    @wedding = Wedding.find_by!(slug: params[:slug])
    @events = @wedding.events.upcoming.ordered
  end
end
