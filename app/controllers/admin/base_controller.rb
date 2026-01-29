class Admin::BaseController < ApplicationController
  include AdminAuthentication

  layout 'admin'

  private

  def current_wedding
    @current_wedding ||= Wedding.first
  end

  helper_method :current_wedding
end
