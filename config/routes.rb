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

  # --- 2. Public Side ---
  
  # THIS IS THE MISSING LINE THAT FIXES YOUR ERROR:
  get 'services', to: 'pages#services'

  # Redirect old/broken links back to the form
  get '/quotes', to: redirect('/quotes/new')

  resources :quotes, only: [:new, :create, :show]

  # Make the "Get a Quote" form the homepage
  root "quotes#new"

  # Health Check
  get "up" => "rails/health#show", as: :rails_health_check
end