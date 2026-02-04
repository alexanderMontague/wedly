module Public
  class BaseController < ApplicationController
    include WeddingConcern

    layout "public"
  end
end
