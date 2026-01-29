class Admin::EventsController < Admin::BaseController
  before_action :set_event, only: [:show, :edit, :update, :destroy]

  def index
    @events = current_wedding.events.ordered
  end

  def show
  end

  def new
    @event = current_wedding.events.build
  end

  def create
    @event = current_wedding.events.build(event_params)

    if @event.save
      redirect_to admin_events_path, notice: "Event created successfully"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @event.update(event_params)
      redirect_to admin_events_path, notice: "Event updated successfully"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @event.destroy
    redirect_to admin_events_path, notice: "Event deleted successfully"
  end

  private

  def set_event
    @event = current_wedding.events.find(params[:id])
  end

  def event_params
    params.require(:event).permit(:name, :datetime, :location, :description)
  end
end
