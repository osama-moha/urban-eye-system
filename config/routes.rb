Rails.application.routes.draw do
  # --- 1. System Admin & Login ---
  devise_for :system_admins

  namespace :admin do
    resources :leads
    
    resources :quotes do
      member do
        patch :update_status 
      end
    end
    
    root to: "leads#index"
  end

  # --- 2. Public Side (The Fix) ---
  
  # Redirect anyone looking for a list of quotes back to the "New Quote" form
  # This stops the "RoutingError" you saw in the logs
  get '/quotes', to: redirect('/quotes/new')

  resources :quotes, only: [:new, :create, :show]

  # Make the "Get a Quote" form the homepage
  root "quotes#new"

  # Health Check
  get "up" => "rails/health#show", as: :rails_health_check
end