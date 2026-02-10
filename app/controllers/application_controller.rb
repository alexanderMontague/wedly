class ApplicationController < ActionController::Base
  def ping
    render plain: "Pong"
  end
end
