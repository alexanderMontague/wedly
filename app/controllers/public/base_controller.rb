module Public
  class BaseController < ApplicationController
    include WeddingConcern
    include SaveTheDateModeEnforcement

    layout "public"
  end
end
