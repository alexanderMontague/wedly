Rails.application.routes.draw do
  get "/rsvp/:code", to: "public/rsvps#edit", as: :rsvp
  patch "/rsvp/:code", to: "public/rsvps#update"
  get "/rsvp/:code/thanks", to: "public/rsvps#thanks", as: :rsvp_thanks

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

  root "public/weddings#show"
end
