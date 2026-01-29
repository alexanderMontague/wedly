class Admin::HouseholdsController < Admin::BaseController
  before_action :set_household, only: [:show, :edit, :update, :destroy]

  def index
    @households = current_wedding.households.includes(:guests).order(:name)
  end

  def show
  end

  def new
    @household = current_wedding.households.build
  end

  def create
    @household = current_wedding.households.build(household_params)

    if @household.save
      redirect_to admin_households_path, notice: "Household created successfully"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @household.update(household_params)
      redirect_to admin_households_path, notice: "Household updated successfully"
    else
      render :edit, status: :unprocessable_entity
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
    params.require(:household).permit(:name)
  end
end
