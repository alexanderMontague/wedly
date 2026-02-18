module Dispo
  class BaseController < ApplicationController
    layout "dispo"

    private

    def current_wedding
      @current_wedding ||= Wedding.current
    end
    helper_method :current_wedding
  end
end
