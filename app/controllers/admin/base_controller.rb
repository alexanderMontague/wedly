module Admin
  class BaseController < ApplicationController
    include AdminAuthentication

    layout "admin"

    private

    def current_wedding
      @current_wedding ||= Wedding.current
    end

    helper_method :current_wedding
  end
end
