module Public
  class RsvpsController < ApplicationController
    layout "public"
    before_action :set_wedding
    before_action :set_guest, only: %i[edit update thanks]

    def index
    end

    def search
      query = params[:q].to_s.strip
      @results = []

      if query.length >= 2
        @results = @wedding.guests
                           .includes(:household)
                           .where("LOWER(first_name) LIKE :q OR LOWER(last_name) LIKE :q", q: "%#{query.downcase}%")
                           .limit(10)
                           .map do |guest|
          {
            id: guest.id,
            name: guest.full_name,
            household: guest.household.name,
            invite_code: guest.invite_code
          }
        end
      end

      render json: @results
    end

    def edit
      @household = @guest.household
      @guests = @household.guests.includes(:rsvp)
      @meal_options = @wedding.meal_options
    end

    def update
      result = RSVPService.submit!(
        household: @guest.household,
        rsvp_params: rsvp_params
      )

      if result[:success]
        redirect_to public_rsvp_thanks_path(@guest.invite_code),
                    notice: "Thank you for your RSVP!"
      else
        @household = @guest.household
        @guests = @household.guests.includes(:rsvp)
        @meal_options = @wedding.meal_options
        flash.now[:alert] = result[:error]
        render :edit, status: :unprocessable_content
      end
    end

    def thanks
    end

    private

    def set_wedding
      @wedding = Wedding.current
    end

    def set_guest
      @guest = Guest.find_by!(invite_code: params[:code])
    end

    def rsvp_params
      params.require(:rsvps).permit!
    end
  end
end
