module Admin
  class HouseholdsController < Admin::BaseController
    before_action :set_household, only: %i[show edit update destroy]

    def index
      @households = current_wedding.households.includes(:guests).order(:created_at)
    end

    def show; end

    def new
      @household = current_wedding.households.build
      @household.guests.build
    end

    def edit
      @household.guests.build if @household.guests.empty?
    end

    def create
      @household = current_wedding.households.build(household_params)

      if @household.save
        redirect_to admin_households_path, notice: "Household created successfully"
      else
        render :new, status: :unprocessable_content
      end
    end

    def update
      if @household.update(household_params)
        redirect_to admin_households_path, notice: "Household updated successfully"
      else
        render :edit, status: :unprocessable_content
      end
    end

    def destroy
      @household.destroy
      redirect_to admin_households_path, notice: "Household deleted successfully"
    end

    private

    def set_household
      @household = current_wedding.households.find(params[:id])
    end

    def household_params
      params.require(:household).permit(
        :name,
        guests_attributes: %i[id first_name last_name email address phone_number _destroy]
      )
    end
  end
end
