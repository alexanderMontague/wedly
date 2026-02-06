Rails.application.routes.draw do
  get "/save-the-date", to: "public/save_the_dates#show", as: :public_save_the_date
  get "/calendar.ics", to: "public/save_the_dates#calendar", as: :public_calendar_ics

  get "/rsvp", to: "public/rsvps#index", as: :public_rsvp_lookup
  get "/rsvp/search", to: "public/rsvps#search", as: :public_rsvp_search
  get "/rsvp/:code", to: "public/rsvps#edit", as: :public_rsvp
  patch "/rsvp/:code", to: "public/rsvps#update"
  get "/rsvp/:code/thanks", to: "public/rsvps#thanks", as: :public_rsvp_thanks

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
