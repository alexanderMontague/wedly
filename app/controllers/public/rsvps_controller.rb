class Public::RSVPsController < ApplicationController
  layout 'public'
  before_action :set_guest

  def edit
    @household = @guest.household
    @guests = @household.guests.includes(:rsvp)
    @wedding = @guest.wedding
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
      @wedding = @guest.wedding
      @meal_options = @wedding.meal_options
      flash.now[:alert] = result[:error]
      render :edit, status: :unprocessable_entity
    end
  end

  def thanks
    @wedding = @guest.wedding
  end

  private

  def set_guest
    @guest = Guest.find_by!(invite_code: params[:code])
  end

  def rsvp_params
    params.require(:rsvps).permit!
  end
end
