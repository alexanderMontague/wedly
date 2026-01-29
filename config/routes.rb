Rails.application.routes.draw do
  namespace :public do
    get "/w/:slug", to: "weddings#show", as: :wedding
    get "/rsvp/:code", to: "rsvps#edit", as: :rsvp
    patch "/rsvp/:code", to: "rsvps#update"
    get "/rsvp/:code/thanks", to: "rsvps#thanks", as: :rsvp_thanks
  end

  namespace :admin do
    get "/login", to: "sessions#new", as: :login
    post "/login", to: "sessions#create"
    delete "/logout", to: "sessions#destroy", as: :logout

    root "dashboard#index"

    resources :events
    resources :guests do
      collection do
        get :export
      end
    end
    resources :households
    resources :invitations, only: %i[index create]
    resource :settings, only: %i[show update]
  end

  root "public/home#index"
end
